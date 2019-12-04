#!/bin/sh

# populate environment datas into config files
sed -i "s/myhostname =.*/myhostname = ${HOSTNAME:-localhost}/g" /etc/postfix/main.cf
sed -i "s/myorigin =.*/myorigin = ${HOSTNAME:-localhost}/g" /etc/postfix/main.cf
sed -i "s@mycustomnetworks =.*@mycustomnetworks = ${CUSTOM_NETWORKS:-}@g" /etc/postfix/main.cf

find /etc/postfix/ -type f -name '*_maps.cf' | xargs sed -i "s/user =.*/user = ${MYSQL_USER:-mail}/g"
find /etc/postfix/ -type f -name '*_maps.cf' | xargs sed -i "s/password =.*/password = ${MYSQL_PASSWORD:-mail}/g"
find /etc/postfix/ -type f -name '*_maps.cf' | xargs sed -i "s/hosts =.*/hosts = ${MYSQL_HOST:-localhost}/g"
find /etc/postfix/ -type f -name '*_maps.cf' | xargs sed -i "s/dbname =.*/dbname = ${MYSQL_DATABASE:-mail}/g"

sed -i "s/connect =.*/connect = host=${MYSQL_HOST:-localhost} dbname=${MYSQL_DATABASE:-mail} user=${MYSQL_USER:-mail} password=${MYSQL_PASSWORD:-mail}/g" /etc/dovecot/dovecot-sql.conf.ext

sed -i "s/postmaster_address =.*/postmaster_address = ${POSTMASTER:-postmaster@example.com}/g" /etc/dovecot/dovecot.conf

# start services
service syslog-ng start
        dovecot
        postfix start
        spamd &

chmod 777 /var/spool/postfix/maildrop/

tail -f /var/log/mail.log
