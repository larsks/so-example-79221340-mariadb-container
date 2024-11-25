#!/bin/bash

service mysql start

mysql_install_db --initialize --user=root --user=$MARIADB_USER --datadir=? --basedir=?

echo "Creating user and db..."
cat << EOF > /etc/mysql/init.sql
    CREATE DATABASE IF NOT EXISTS $MARIADB_DATABASE;
    CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';
    GRANT ALL PRIVILEGES ON $MARIADB_DATABASE.* TO '$MARIADB_USER'@'%';
    FLUSH PRIVILEGES;
EOF
mysql < /etc/mysql/init.sql

echo "Database and user successfully created."

kill $(cat /var/run/mysqld/mysqld.pid)

exec mysqld
