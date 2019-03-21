#!/bin/bash
PPP=$1

#mkdir $PPP ; cd $PPP

# Пример пустого ляпис проекта для теста
#lapis new --lua
#mkdir logs
#LAPIS_PORT=9999 lapis build production

S=$(basename `pwd`)
P=$(pwd)/
mkdir -p ~/.config/systemd/user/

cat << EOF > ~/.config/systemd/user/$S.service
[Unit]
Description=$S
After=network.target

[Service]
Type=simple
WorkingDirectory=$P
ExecStart=/usr/local/openresty/nginx/sbin/nginx -p $P -c 'nginx.conf.compiled'
ExecStop=/bin/kill -s SIGINT $MAINPID
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user start $PPP
systemctl --user enable $PPP