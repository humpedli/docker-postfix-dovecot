#!/bin/sh

# populate environment datas into config files
RUN sed -i "s/myhostname =.*/myhostname = ${HOSTNAME:-localhost}/g" /etc/postfix/main.cf
RUN sed -i "s/myorigin =.*/myhostname = ${HOSTNAME:-localhost}/g" /etc/postfix/main.cf

RUN sed -i "s/user =.*/user = ${MYSQL_USER:-mail}/g" /etc/postfix/*
RUN sed -i "s/password =.*/password = ${MYSQL_PASSWORD:-mail}/g" /etc/postfix/*
RUN sed -i "s/hosts =.*/hosts = ${MYSQL_HOST:-localhost}/g" /etc/postfix/*
RUN sed -i "s/port =.*/port = ${MYSQL_PORT:-3306}/g" /etc/postfix/*
RUN sed -i "s/dbname =.*/dbname = ${MYSQL_DATABASE:-mail}/g" /etc/postfix/*

RUN sed -i "s/connect =.*/connect = host=${MYSQL_HOST:-localhost} dbname=${MYSQL_DATABASE:-mail} user=${MYSQL_USER:-mail} password=${MYSQL_PASSWORD:-mail}/g" /etc/dovecot/dovecot-sql.conf.ext

RUN sed -i "s/postmaster_address =.*/postmaster_address = ${POSTMASTER:-postmaster@example.com}/g" /etc/dovecot/dovecot.conf

# start services
/etc/init.d/postfix start
/etc/init.d/rsyslog start
/etc/init.d/spamassassin start
/usr/sbin/dovecot -F