version=(${1//"apache-druid-"/ })

sudo sysctl -w vm.max_map_count=262144
sudo echo "vm.max_map_count=262144" >> /etc/sysctl.conf

wget https://dlcdn.apache.org/druid/$version/$1-bin.tar.gz

tar -xvf $1-bin.tar.gz

mkdir ./$1/conf/druid/cluster/historical/historical

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
