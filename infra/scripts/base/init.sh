#!/bin/bash
sudo -u ubuntu -i <<'EOF'

cd /home/ubuntu

sudo apt install -y openjdk-17-jdk unzip htop vim curl
sudo apt install -y unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip

sudo ./aws/install --bin-dir /usr/bin --install-dir /usr/local/aws-cli --update;

wget https://raw.githubusercontent.com/dayknightmare/druid-archt-ops/master/infra/scripts/base/install.sh
wget https://raw.githubusercontent.com/dayknightmare/druid-archt-ops/master/infra/scripts/base/cw-exporter.sh
wget https://raw.githubusercontent.com/dayknightmare/druid-archt-ops/master/infra/scripts/base/get_masters_zk.sh

sudo chmod +x install.sh
sudo chmod +x cw-exporter.sh
sudo chmod +x get_masters_zk.sh

fullversion=${druid_version}
version=($${fullversion//"apache-druid-"/ })

./install.sh $fullversion

echo '${base_common}' > $fullversion/conf/druid/cluster/_common/common.runtime.properties

EOF

export AWS_ACCESS_KEY_ID=$access_key
export AWS_SECRET_ACCESS_KEY=$secret_key

aws ssm put-parameter --name "UserDataBaseCompletion" --value "completed" --type "String" --overwrite --region $region
