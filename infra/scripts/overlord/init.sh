#!/bin/bash
${base_common}

cat <<EOL > /etc/systemd/system/druid.service
${overlord_daemon}
EOL

sudo chmod +x /etc/systemd/system/druid.service

sudo -u ec2-user -i <<'EOF'

cd /home/ec2-user

cat <<EOL > druid/conf/druid/cluster/master/coordinator-overlord/runtime.properties
${overlord_common}
EOL

cat <<EOL > druid/conf/druid/cluster/master/coordinator-overlord/jvm.config
${overlord_jvm}
EOL

sudo systemctl daemon-reload
sudo systemctl enable druid.service
sudo systemctl start druid.service
EOF

echo '* * * * * root /home/ec2-user/cw_exporter.sh overlord' >> /etc/crontab

echo "1" > "/home/ec2-user/finished.txt"