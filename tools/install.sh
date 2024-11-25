#!/bin/bash

mysql_install_db --user=mysql --datadir=/var/lib/mysql --basedir=/usr

echo "Starting temporary server"
mysqld --skip-networking --default-time-zone=SYSTEM --socket="/var/run/mysqld/mysqld.sock" --wsrep_on=OFF \
		--expire-logs-days=0 \
		--skip-slave-start \
		--loose-innodb_buffer_pool_load_at_startup=0 \
		--skip-ssl &

echo "Waiting for database startup"
while :; do
  echo -n '.'
  if mysql --database=mysql --skip-ssl <<<'SELECT 1' &> /dev/null; then
    break
  fi
  sleep 1
done
echo

echo "Creating user and db..."
cat << EOF > /etc/mysql/init.sql
    CREATE DATABASE IF NOT EXISTS $MARIADB_DATABASE;
    CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';
    GRANT ALL PRIVILEGES ON $MARIADB_DATABASE.* TO '$MARIADB_USER'@'%';
    FLUSH PRIVILEGES;
EOF
mysql < /etc/mysql/init.sql

echo "Database and user successfully created."
echo "Stopping temporary server"
kill $(cat /var/run/mysqld/mysqld.pid)

echo "Starting persistent server"
exec mysqld
