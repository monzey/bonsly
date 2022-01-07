#! /bin/bash 

installAnsible () {
  echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" | tee -a /etc/apt/sources.list
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
  apt update
  apt install ansible

  # launch playbook
  ansible-playbook playbook.yaml --ask-become-pass -vvv
}
