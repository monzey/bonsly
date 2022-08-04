#! /bin/bash 

installAnsible () {
  apt install curl gnupg -y
  echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" | tee -a /etc/apt/sources.list
  curl -sL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x93C4A3FD7BB9C367" | apt-key add
  apt update
  apt install ansible -y

  # launch playbook
  ansible-galaxy collection install community.general
  ansible-playbook playbook.yaml --ask-become-pass -vvv
}

installAnsible
