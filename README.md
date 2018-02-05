# mi-core-munin

This repository is based on [Joyent mibe](https://github.com/joyent/mibe). Please note this repository should be build with the [mi-core-base](https://github.com/skylime/mi-core-base) mibe image.

## mdata variables

No mdata variable is required. Everything could be automatically generated on
provision state. We recommend a valid `nginx_ssl` certificate.

- `nginx_ssl`: ssl certificate for nginx web interface
- `munin_admin`: admin password for munin admin interface

## services

- `80/tcp`: http webserver
- `443/tcp`: https webserver

## installation

The following sample can be used to create a zone running a copy of the the nextcloud image.

```
IMAGE_UUID=$(imgadm list | grep 'qutic-munin' | tail -1 | awk '{ print $1 }')
vmadm create << EOF
{
  "brand":      "joyent",
  "image_uuid": "$IMAGE_UUID",
  "alias":      "munin-server",
  "hostname":   "munin.example.com",
  "dns_domain": "example.com",
  "resolvers": [
    "80.80.80.80",
    "80.80.81.81"
  ],
  "nics": [
    {
      "interface": "net0",
      "nic_tag":   "admin",
      "ip":        "10.10.10.10",
      "gateway":   "10.10.10.1",
      "netmask":   "255.255.255.0"
    }
  ],
  "max_physical_memory": 1024,
  "max_swap":            1024,
  "quota":                 10,
  "cpu_cap":              100,
  "customer_metadata": {
    "admin_authorized_keys": "your-long-key",
    "root_authorized_keys":  "your-long-key",
    "mail_smarthost":        "mail.example.com",
    "mail_auth_user":        "you@example.com",
    "mail_auth_pass":        "smtp-account-password",
    "mail_adminaddr":        "report@example.com",
    "munin_master_allow":    "munin-master-ip",
    "vfstab":                "storage.example.com:/export/munin    -       /data    nfs     -       yes     rw,bg,intr",
    "nginx_ssl":             "certificat-with-encoded-linebreaks",
    "nginx_htpasswd":        "jerry:my-secret-password",
    "munin_admin":           "munin-admin-password"
  }
}
EOF
```
