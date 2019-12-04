# Dockerized Postfix and Dovecot

Postfix with Dovecot, Spamassasin, SPF record check and mysql support with linked container

## Usage

* Create a MySQL container and import `postfix.sql` file to create the database
* Insert an user into previously created database
* Run container with the following configuration:

---
**Docker command:**

```bash
docker run --name=postfix-dovecot \
  --restart=always \
  -v <path_to_cert/cert.pem>:/etc/ssl/certs/fullchain.pem:ro \
  -v <path_to_key/key.pem>:/etc/ssl/private/privkey.pem:ro \
  -v <path_to_mails>:/home/vmail \
  -v /etc/localtime:/etc/localtime:ro \
  --link mysql:mysql \
  -e HOSTNAME=example.com \
  -e CUSTOM_NETWORKS='172.18.0.0/16' \
  -e POSTMASTER=postmaster@example.com \
  -e MYSQL_HOST=mysql \
  -e MYSQL_PORT=3306 \
  -e MYSQL_USER=<mysql_user> \
  -e MYSQL_PASSWORD=<mysql_password> \
  -e MYSQL_DATABASE=<mysql_database> \
  -p 25:25 \
  -p 587:587 \
  -p 993:993 \
  -d humpedli/docker-postfix-dovecot
```

---
**Docker compose:**

```bash
version: '3'
services:
  postfix-dovecot:
    container_name: "postfix-dovecot"
    image: "humpedli/docker-postfix-dovecot"
    ports:
      - "25:25"
      - "587:587"
      - "993:993"
    volumes:
      - "<path_to_cert/cert.pem>:/etc/ssl/certs/fullchain.pem:ro"
      - "<path_to_key/key.pem>:/etc/ssl/private/privkey.pem:ro"
      - "<path_to_mails>:/home/vmail"
      - "/etc/localtime:/etc/localtime:ro"
    environment:
      - "HOSTNAME=example.com"
      - "CUSTOM_NETWORKS=172.18.0.0/16"
      - "POSTMASTER=postmaster@example.com"
      - "MYSQL_HOST=mysql"
      - "MYSQL_PORT=3306"
      - "MYSQL_USER=<mysql_user>"
      - "MYSQL_PASSWORD=<mysql_password>"
      - "MYSQL_DATABASE=<mysql_database>"
    depends_on:
      - mysql
    restart: "always"
```

## Usage with postfixadmin

Postfixadmin is an admin application for postfix.

* Run project as explain in next section. Fill free to update env var as
  needed
* Run postfixadmin setup.php script

**Docker compose With postfix admin:**

```bash
version: '3'
services:
  postfix-dovecot:
    container_name: "postfix-dovecot"
    image: "humpedli/docker-postfix-dovecot"
    ports:
      - "25:25"
      - "587:587"
      - "993:993"
    volumes:
      - "<path_to_cert/cert.pem>:/etc/ssl/certs/fullchain.pem:ro"
      - "<path_to_key/key.pem>:/etc/ssl/private/privkey.pem:ro"
      - "<path_to_mails>:/home/vmail"
      - "/etc/localtime:/etc/localtime:ro"
    environment:
      - "HOSTNAME=example.com"
      - "CUSTOM_NETWORKS=172.18.0.0/16"
      - "POSTMASTER=postmaster@example.com"
      - "MYSQL_HOST=mysql"
      - "MYSQL_PORT=3306"
      - "MYSQL_USER=<mysql_user>"
      - "MYSQL_PASSWORD=<mysql_password>"
      - "MYSQL_DATABASE=<mysql_database>"
    depends_on:
      - mysql
    restart: "always"
  mysql:
    image: mariadb:10
    environment:
      - "MYSQL_ROOT_PASSWORD=<mysql_root_pwd>"
      - "MYSQL_USER=<mysql_user>"
      - "MYSQL_PASSWORD=<mysql_password>"
      - "MYSQL_DATABASE=mail"
    volumes:
      - ./mysql:/var/lib/mysql
  admin:
    image: postfixadmin
    environment:
      POSTFIXADMIN_DB_TYPE: mysqli
      POSTFIXADMIN_DB_HOST: mysql
      POSTFIXADMIN_DB_USER: <mysql_user> 
      POSTFIXADMIN_DB_PASSWORD: <mysql_password>
      POSTFIXADMIN_DB_NAME: mail
    ports:
      - 8080:80
```

postfixadmin setup script is available at
http://localhost:8080/setup.php


## Development 

### Create local certificat


```bash
$ openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem
```


