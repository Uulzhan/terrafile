#!/bin/bash
sudo yum update -y
sudo yum install git -y
sudo wget -O /etc/yum.repos.d/jenkins.repo  https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum upgrade
sudo yum install -y jenkins java-1.8.0-openjdk-devel
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

