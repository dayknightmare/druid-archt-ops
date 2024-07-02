#!/bin/bash
fullversion=${druid_version}
version=($${fullversion//"apache-druid-"/ })

echo '${overlord_common}' > $fullversion/conf/druid/cluster/master/coordinator-overlord/common.runtime.properties
echo '${overlord_jvm}' > $fullversion/conf/druid/cluster/master/coordinator-overlord/jvm.config

echo '${overlord_daemon}' > /etc/systemd/system/druid.service
sudo chmod +x /etc/systemd/system/druid.service

sudo systemctl daemon-reload
sudo systemctl enable druid.service
sudo systemctl start druid.service
