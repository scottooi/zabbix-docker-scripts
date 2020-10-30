echo "MYSQL PASSWORD:"
read mysql_password
echo "MYSQL ROOT PASSWORD:"
read mysql_root_password

mkdir -p /mnt/data/mysql
chown -R 999:999 /mnt/data/mysql
mkdir -p /etc/ssl/apache2

docker network create zabbix-network

docker run --name mysql-server -t \
	-e MYSQL_DATABASE="zabbix" \
	-e MYSQL_USER="zabbix" \
	-e MYSQL_PASSWORD="$mysql_password" \
	-e MYSQL_ROOT_PASSWORD="$mysql_root_password" \
	--network="zabbix-network" \
	-v /mnt/data/mysql:/var/lib/mysql \
	--restart unless-stopped \
	-d mysql:8.0 \
	--character-set-server=utf8 --collation-server=utf8_bin \
	--default-authentication-plugin=mysql_native_password

docker run --name zabbix-server-mysql -t \
	-e DB_SERVER_HOST="mysql-server" \
	-e MYSQL_DATABASE="zabbix" \
	-e MYSQL_USER="zabbix" \
	-e MYSQL_PASSWORD="$mysql_password" \
	-e MYSQL_ROOT_PASSWORD="$mysql_root_password" \
	--network="zabbix-network" \
	-p 10051:10051 \
	--restart unless-stopped \
	-d zabbix/zabbix-server-mysql:ubuntu-latest

docker run --name zabbix-web-apache-mysql -t \
	-e ZBX_SERVER_HOST="zabbix-server-mysql" \
	-e DB_SERVER_HOST="mysql-server" \
	-e MYSQL_DATABASE="zabbix" \
	-e MYSQL_USER="zabbix" \
	-e MYSQL_PASSWORD="$mysql_password" \
	-e MYSQL_ROOT_PASSWORD="$mysql_root_password" \
	-e PHP_TZ="Australia/Adelaide" \
	--network="zabbix-network" \
	-p 443:8443 \
	-v /etc/ssl/apache2:/etc/ssl/apache2:ro \
	--restart unless-stopped \
	-d zabbix/zabbix-web-apache-mysql:ubuntu-latest

echo ">> created /mnt/data/mysql to persist data"
echo ">> created /etc/ssl/apache2 for ssl.crt & ssl.key"
