FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

# install packages
RUN apt-get update 
RUN apt-get install -y wget \
                       postfix-mysql \
                       postfix-policyd-spf-python \
                       dovecot-core \
                       dovecot-mysql \
                       dovecot-imapd \
                       dovecot-lmtpd \
                       spamassassin \
                       rsyslog

# add vmail user and group
RUN mkdir /var/vmail
RUN groupadd -g 5000 vmail
RUN useradd -u 111 -g 5000 -d /var/vmail -s /usr/sbin/nologin vmail
RUN chown -R vmail:vmail /var/vmail

# cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# disable kernel log
RUN sed -i 's/module(load="imklog" permitnonkernelfacility="on")/#module(load="imklog" permitnonkernelfacility="on")/g' /etc/rsyslog.conf

# enable spamassassin
RUN sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin

# copy configurations
COPY dovecot /etc/dovecot
COPY postfix /etc/postfix

# run mysql configuration creator script
COPY run.sh /run.sh
RUN chmod u+x /run.sh

# entry point
ENTRYPOINT ["/run.sh"]

# define important volumes
VOLUME [ "/var/log/", "/var/vmail/" ]

# expose important ports
EXPOSE 25 465 993