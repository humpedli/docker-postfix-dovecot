FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

# install packages
RUN apt-get update 
RUN apt-get install -y syslog-ng-core \
                       syslog-ng \
                       postfix \
                       postfix-mysql \
                       dovecot-core \
                       dovecot-mysql \
                       dovecot-imapd \
                       dovecot-lmtpd \
                       spamassassin \
                       postfix-policyd-spf-python

# add vmail user and group
RUN groupadd -g 5000 vmail
RUN useradd -g vmail -u 5000 vmail -d /home/vmail
RUN mkdir /home/vmail
RUN chown -R vmail:vmail /home/vmail

# copy dovecot and postfix configurations
COPY dovecot /etc/dovecot
COPY postfix /etc/postfix

# enable spamassassin
RUN sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin

# copy run script
COPY run.sh /run.sh
RUN chmod u+x /run.sh

# cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# entry point
CMD ["/run.sh"]