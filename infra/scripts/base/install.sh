#!/bin/bash
version=(${1//"apache-druid-"/ })

sudo sysctl -w vm.max_map_count=800000
sudo sh -c 'echo "vm.max_map_count=800000" >> /etc/sysctl.conf'
sudo sh -c 'echo "* soft nofile 800000" >> /etc/security/limits.conf'
sudo sh -c 'echo "* hard nofile 800000" >> /etc/security/limits.conf'
sudo sysctl -p

wget https://dlcdn.apache.org/druid/$version/$1-bin.tar.gz

tar -xvf $1-bin.tar.gz

mkdir $1/conf/druid/cluster/historical/historical

wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar -P $1/extensions/mysql-metadata-storage

echo ":verify bin/verify-java

middleManager bin/run-druid middleManager conf/druid/cluster/data
" > $1/conf/supervise/cluster/data.conf

echo ":verify bin/verify-java

historical bin/run-druid historical conf/druid/cluster/historical
" > $1/conf/supervise/cluster/historical.conf

echo 'PWD="$(pwd)"
WHEREAMI="$(dirname "$0")"
WHEREAMI="$(cd "$WHEREAMI" && pwd)"

exec "$WHEREAMI/supervise" -c "$WHEREAMI/../conf/supervise/cluster/historical.conf"
' > $1/bin/start-cluster-historical-server

chmod 744 $1/conf/supervise/cluster/historical.conf
chmod 744 $1/conf/supervise/cluster/data.conf
chmod 744 $1/bin/start-cluster-historical-server