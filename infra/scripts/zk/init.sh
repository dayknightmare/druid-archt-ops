#!/bin/bash
export AWS_ACCESS_KEY_ID=${access_key}
export AWS_SECRET_ACCESS_KEY=${secret_key}

cat <<EOF > /etc/systemd/system/druid.service
[Unit]
Description=druid zookeeper service
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/zookeeper/bin
ExecStart=sh -c "./zkServer.sh start-foreground"

[Install]
WantedBy=multi-user.target
EOF

sudo chmod +x /etc/systemd/system/druid.service

sudo -u ec2-user -i <<'EOF'

cd /home/ec2-user

sudo yum update

while sudo yum install cronie java-17-amazon-corretto nc jq htop -y; [[ $? -ne 0 ]];
do
    echo "<zookeeper> Will retry in 5 seconds. $(date)"
    sleep 5
done

while sudo yum groupinstall "Development Tools" -y; [[ $? -ne 0 ]];
do
    echo "<zookeeper> Will retry in 5 seconds. $(date)"
    sleep 5
done

curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip

sudo ./aws/install --bin-dir /usr/bin --install-dir /usr/local/aws-cli --update

aws configure set aws_access_key_id ${access_key}
aws configure set aws_secret_access_key ${secret_key}
aws configure set aws_region ${region}

wget https://dlcdn.apache.org/zookeeper/zookeeper-${zk_version}/apache-zookeeper-${zk_version}-bin.tar.gz
tar -xzf apache-zookeeper-${zk_version}-bin.tar.gz
mv apache-zookeeper-${zk_version}-bin zookeeper

mkdir -p /home/ec2-user/zookeeper/data/zk
mkdir -p /home/ec2-user/zookeeper/data/zklogs

echo ${zk_id} > /home/ec2-user/zookeeper/data/zk/myid

sleep 10

AWS_IPS_ZK=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=${cluster_name}-druid-zk*' 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value, PrivateDnsName]' --output json | jq -c '[.].[].[].[]')

result=''

for ip in $AWS_IPS_ZK; do
   server_id=$(echo $ip | jq '.[0].[0]' | sed 's/"//g' | tr "${cluster_name}-druid-zk-" " " | awk '{print $1}')
   server_ip=$(echo $ip | jq '.[1]' | sed 's/"//g')

   result+="server.$server_id=$server_ip:2888:3888"
   result+=$'\n'
done

> /home/ec2-user/zookeeper/conf/zoo.cfg.dynamic

for i in $result; do
    echo $i >> /home/ec2-user/zookeeper/conf/zoo.cfg.dynamic;
done

echo 'clientPort=2181
tickTime=2000
dataDir=/home/ec2-user/zookeeper/data/zk
dataLogDir=/home/ec2-user/zookeeper/data/zklogs
initLimit=5
syncLimit=2
maxClientCnxns=0
standaloneEnabled=false
reconfigEnabled=true
4lw.commands.whitelist=*
skipACL=yes
autopurge.snapRetainCount=5
autopurge.purgeInterval=1
dynamicConfigFile=/home/ec2-user/zookeeper/conf/zoo.cfg.dynamic
' > /home/ec2-user/zookeeper/conf/zoo.cfg

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

echo "export AWS_ACCESS_KEY_ID=${access_key}" >> ~/.bashrc
echo "export AWS_SECRET_ACCESS_KEY=${secret_key}" >> ~/.bashrc
echo "export AWS_SECRET_KEY=${secret_key}" >> /home/ec2-user/.bashrc

source ~/.bashrc

sudo chmod +x cw_exporter.sh
sudo systemctl daemon-reload
sudo systemctl enable druid.service
sudo systemctl start druid.service
sudo systemctl enable crond.service
sudo systemctl start crond.service
EOF

echo "1" > "/home/ec2-user/finished.txt"

echo '* * * * * root /home/ec2-user/cw_exporter.sh zk' >> /etc/crontab
