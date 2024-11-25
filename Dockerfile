FROM debian:buster

RUN apt update && apt-get upgrade -y
RUN apt install mariadb-server -y

COPY ./conf/50.server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/install.sh ./install.sh
RUN chmod +x install.sh

RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql

EXPOSE 3306

CMD [ "./install.sh" ]
