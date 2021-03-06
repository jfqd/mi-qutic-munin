# This script will try to manage the ssl certificates for us. It will
# use the mdata variable if provided, if it does not exists we will
# try to get a certificate from the Let's Encrypt API.
# As fallback the self-signed certificate is used from 45-ssl-selfsigned.sh

# Default
SSL_HOME='/opt/local/etc/nginx/ssl/'

# Create folder if it doesn't exists
mkdir -p "${SSL_HOME}"
chmod 0750 "${SSL_HOME}"

# Use user certificate if provided
if mdata-get nginx_ssl 1>/dev/null 2>&1; then
  (
  umask 0077
  mdata-get nginx_ssl > "${SSL_HOME}/nginx.pem"
  # Split files for nginx usage
  openssl pkey -in "${SSL_HOME}/nginx.pem" -out "${SSL_HOME}/nginx.key"
  openssl crl2pkcs7 -nocrl -certfile "${SSL_HOME}/nginx.pem" | \
    openssl pkcs7 -print_certs -out "${SSL_HOME}/nginx.crt"
  )
  chmod 0640 "${SSL_HOME}"/nginx.*
elif /opt/qutic/bin/ssl-letsencrypt.sh -t webroot 1>/dev/null; then
  # Try to generate let's encrypt ssl certificate for the hostname
  LE_HOME='/opt/local/etc/letsencrypt/'
  LE_LIVE="${LE_HOME}live/$(hostname)/"
  # Workaround to link correct files for SSL_HOME
  ln -sf ${LE_LIVE}/fullchain.pem ${SSL_HOME}/nginx.crt
  ln -sf ${LE_LIVE}/privkey.pem ${SSL_HOME}/nginx.key
  # Update renew-hook.sh
  echo '#!/usr/bin/env bash' > ${LE_HOME}renew-hook.sh
  echo 'svcadm restart svc:/pkgsrc/nginx:default' >> ${LE_HOME}renew-hook.sh
  chmod 0640 "${SSL_HOME}"/nginx.*
fi

# create htpasswd file
if mdata-get nginx_htpasswd 1>/dev/null 2>&1; then
  user=$(mdata-get nginx_htpasswd | tr ":"  "\n" | sed -n 1p)
  pass=$(mdata-get nginx_htpasswd | tr ":"  "\n" | sed -n 2p)
  crypt=$(openssl passwd -apr1 $pass)
  echo "$user:$crypt" > /opt/local/etc/nginx/.htpasswd
  chown www:root /opt/local/etc/nginx/.htpasswd
  chmod 0640 /opt/local/etc/nginx/.htpasswd
fi

# Always run a restart of the webserver
svcadm restart svc:/pkgsrc/nginx:default
