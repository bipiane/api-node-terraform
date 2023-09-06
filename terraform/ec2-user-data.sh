#!/bin/bash
### Install GIT
yum update -y
yum install -y git

### Install NVM
touch ~/.bashrc
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
source ~/.bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

### Clone project and install dependencies
cd /home/ec2-user
su ec2-user -c "git clone https://github.com/bipiane/api-node-terraform.git"
cd api-node-terraform
git pull origin main
nvm install # gets node version from .nvmrc
npm install
npm run build
npm run start

# Log into the instance with "EC2 Instance Connect" or SSH, and check logs
# tail -f /var/log/cloud-init-output.log
