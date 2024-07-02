#!/bin/bash
sudo apt install -y openjdk-17-jdk unzip htop vim curl

cd /home/ubuntu

wget https://raw.githubusercontent.com/dayknightmare/druid-archt-ops/master/infra/scripts/base/install.sh

sudo chmod +x install.sh

fullversion=${druid_version}
version=($${fullversion//"apache-druid-"/ })

./install.sh $fullversion

echo '${base_common}' > /home/ubuntu/$fullversion/conf/druid/cluster/_common/common.runtime.properties
