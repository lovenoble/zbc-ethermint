#!/bin/bash

cd /home/ubuntu

curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get update
sudo apt-get install nodejs -y

git clone https://github.com/zama-ai/fhevm.git
cd /home/ubuntu/fhevm
cp .env.example .env
npm i

sudo sh -c "cat > /etc/systemd/system/run-fhevm-tests.service" << EOL
[Unit]
Description=Run fhevm tests

[Service]
User=ubuntu
Group=ubuntu
Type=oneshot
ExecStart=/usr/bin/npx hardhat test --network zama
WorkingDirectory=/home/ubuntu/fhevm

[Install]
WantedBy=multi-user.target
EOL

sudo sh -c "cat > /etc/systemd/system/run-fhevm-tests.timer" << EOL
[Unit]
Description=Runs fhe tests every hour
After=network-online.target

[Timer]
OnCalendar=hourly

[Install]
WantedBy=timers.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable run-fhevm-tests.timer
sudo systemctl enable run-fhevm-tests.service
sudo systemctl start run-fhevm-tests.timer
