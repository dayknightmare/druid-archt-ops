#!/bin/bash

${base_common}

echo '${overlord_daemon}' > /etc/systemd/system/druid.service
sudo chmod +x /etc/systemd/system/druid.service

sudo -u ubuntu -i <<'EOF'

fullversion=${druid_version}
version=($${fullversion//"apache-druid-"/ })

cd /home/ubuntu

echo '${overlord_common}' > $fullversion/conf/druid/cluster/master/coordinator-overlord/common.runtime.properties
echo '${overlord_jvm}' > $fullversion/conf/druid/cluster/master/coordinator-overlord/jvm.config

sudo systemctl daemon-reload
sudo systemctl enable druid.service
sudo systemctl start druid.service

EOF

echo '* * * * * root /home/ubuntu/cw_exporter.sh overlord' >> /etc/crontab