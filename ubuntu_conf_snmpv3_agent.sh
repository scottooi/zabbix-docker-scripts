echo "Agent IP Address:"
read agentIPAddress
echo "Authentication Key:"
read authKey
echo "Privacy Key:"
read privKey

apt update
apt install snmpd libsnmp-dev
systemctl stop snmpd
net-snmp-config --create-snmpv3-user -ro -a SHA -x AES -A $authKey -X $privKey zabbix-user

snmpdConf="/etc/snmp/snmpd.conf"
localOnly="^agentAddress  udp:127.0.0.1:161"
disableLocal="#agentAddress  udp:127.0.0.1:161"
allInterfaces="^#agentAddress udp:161,udp6:\[::1\]:161"
enableInterface="agentAddress udp:$agentIPAddress:161"
sed -i "s/$localOnly/$disableLocal/g" $snmpdConf
sed -i "s/$allInterfaces/$enableInterface/g" $snmpdConf

systemctl restart snmpd
