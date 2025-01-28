#!/bin/bash
export AWS_ACCESS_KEY_ID=${access_key}
export AWS_SECRET_ACCESS_KEY=${secret_key}

sudo -u ec2-user -i <<'EOF'

cd /home/ec2-user

sudo yum update

while sudo yum install cronie java-17-amazon-corretto nc jq htop -y; [[ $? -ne 0 ]];
do
    echo "<base> Will retry in 5 seconds. $(date)"
    sleep 5
done

while sudo yum groupinstall "Development Tools" -y; [[ $? -ne 0 ]];
do
    echo "<base> Will retry in 5 seconds. $(date)"
    sleep 5
done

curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip

sudo ./aws/install --bin-dir /usr/bin --install-dir /usr/local/aws-cli --update

cat <<EOL > cw_exporter.sh
INSTANCE_ID=\$(ec2-metadata --instance-id | awk '{print \$2}')
DRUID_NODE_TYPE=\$1

aws cloudwatch --region ${region} put-metric-data --namespace="ECS" --metric-name "CPULoad" --dimensions InstanceId=\$INSTANCE_ID,DruidCluterType=\$DRUID_NODE_TYPE --value \$(cat /proc/loadavg | awk '{print \$1}')
aws cloudwatch --region ${region} put-metric-data --namespace="ECS" --metric-name "CPULoad" --dimensions DruidCluterType=\$DRUID_NODE_TYPE --value \$(cat /proc/loadavg | awk '{print \$1}')

aws cloudwatch --region ${region} put-metric-data --namespace="ECS" --metric-name "MemoryUtilization" --unit=Percent --dimensions InstanceId=\$INSTANCE_ID,DruidCluterType=\$DRUID_NODE_TYPE --value \$(free | grep Mem | awk '{print \$3/\$2 * 100.0}')
aws cloudwatch --region ${region} put-metric-data --namespace="ECS" --metric-name "MemoryUtilization" --unit=Percent --dimensions DruidCluterType=\$DRUID_NODE_TYPE --value \$(free | grep Mem | awk '{print \$3/\$2 * 100.0}')

aws cloudwatch --region ${region} put-metric-data --namespace="ECS" --metric-name "StorageLeft" --unit=Percent --dimensions InstanceId=$INSTANCE_ID,DruidCluterType=\$DRUID_NODE_TYPE --value \$(df | grep -e '^/dev/nvme0n1p1' | awk '{printf 100-(\$3*100)/\$2}')
aws cloudwatch --region ${region} put-metric-data --namespace="ECS" --metric-name "StorageLeft" --unit=Percent --dimensions DruidCluterType=\$DRUID_NODE_TYPE --value \$(df | grep -e '^/dev/nvme0n1p1' | awk '{printf 100-(\$3*100)/\$2}')

aws cloudwatch --region ${region} put-metric-data --namespace="ECS" --metric-name "CPUUsage" --unit=Percent --dimensions InstanceId=\$INSTANCE_ID,DruidCluterType=\$DRUID_NODE_TYPE --value \$(vmstat | tail -1 | awk '{print 100-\$15}')
aws cloudwatch --region ${region} put-metric-data --namespace="ECS" --metric-name "CPUUsage" --unit=Percent --dimensions DruidCluterType=\$DRUID_NODE_TYPE --value \$(vmstat | tail -1 | awk '{print 100-\$15}')
EOL

cat <<EOL > get_masters_zk.sh
IPS=\$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=${cluster_name}-druid-zk*' 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].PrivateDnsName' --output text)

result=""

for ip in \$IPS; do
   result="\$result,\$ip:2181"
done

export DRUID_IPS_ZK=\$${result#*,}
EOL

sudo chmod +x cw_exporter.sh
sudo chmod +x get_masters_zk.sh
sudo sysctl -w vm.max_map_count=800000
sudo sh -c "echo "vm.max_map_count=800000" >> /etc/sysctl.conf"
sudo sh -c "echo "* soft nofile 800000" >> /etc/security/limits.conf"
sudo sh -c "echo "* hard nofile 800000" >> /etc/security/limits.conf"
sudo sysctl -p

wget https://archive.apache.org/dist/druid/${druid_version}/apache-druid-${druid_version}-bin.tar.gz

tar -xvf apache-druid-${druid_version}-bin.tar.gz
mv apache-druid-${druid_version} druid

mkdir /home/ec2-user/druid/conf/druid/cluster/historical
mkdir /home/ec2-user/druid/conf/druid/cluster/historical/historical

wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar -P druid/extensions/mysql-metadata-storage

cat <<EOL > /home/ec2-user/druid/conf/supervise/cluster/data.conf
:verify bin/verify-java

middleManager bin/run-druid middleManager conf/druid/cluster/data
EOL

cat <<EOL > /home/ec2-user/druid/conf/supervise/cluster/historical.conf
:verify bin/verify-java

historical bin/run-druid historical conf/druid/cluster/historical
EOL

cat <<EOL > /home/ec2-user/druid/bin/start-cluster-historical-server
PWD="\$(pwd)"
WHEREAMI="\$(dirname "\$0")"
WHEREAMI="\$(cd "\$WHEREAMI" && pwd)"

exec "\$WHEREAMI/supervise" -c "\$WHEREAMI/../conf/supervise/cluster/historical.conf"
EOL

chmod 744 /home/ec2-user/druid/conf/supervise/cluster/historical.conf
chmod 744 /home/ec2-user/druid/conf/supervise/cluster/data.conf
chmod 744 /home/ec2-user/druid/bin/start-cluster-historical-server

cat <<EOL > /home/ec2-user/druid/conf/druid/cluster/_common/log4j2.xml
${log4j}
EOL

cat <<EOL > /home/ec2-user/druid/conf/druid/cluster/_common/common.runtime.properties
${base_common}
EOL

aws configure set aws_access_key_id ${access_key}
aws configure set aws_secret_access_key ${secret_key}
aws configure set aws_region ${region}

echo "export AWS_ACCESS_KEY_ID=${access_key}" >> ~/.bashrc
echo "export AWS_SECRET_ACCESS_KEY=${secret_key}" >> ~/.bashrc
echo "export AWS_SECRET_KEY=${secret_key}" >> /home/ec2-user/.bashrc

source ~/.bashrc

sudo systemctl enable crond.service
sudo systemctl start crond.service

EOF
