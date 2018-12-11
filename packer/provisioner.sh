#!/bin/bash
yum update -y
yum remove cloud-init -y
yum install epel-release -y
yum clean all
yum install -y python-pip
yum install -y mercurial
pip install awscli --upgrade
yum install -y rsync
service sshd restart
rm -rf ~/.hisotry
