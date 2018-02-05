# create cronjob for ssl-expire script
CRON='0 9 * * 1 /opt/qutic/bin/ssl-expire.sh
15 3 * * 6 /opt/local/sbin/pkg_admin audit
15 * * * * /opt/qutic/bin/check-log /var/adm/messages "(znapzend.*ERROR)"
8 * * * * [[ -x /data/bin/backup ]] && /data/bin/backup 2>&1 1>/dev/null
'
(crontab -l 2>/dev/null || true; echo "$CRON" ) | sort | uniq | crontab
