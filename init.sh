#! /bin/bash 

installAnsible () {
  deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
  sudo apt update
  sudo apt install ansible

  # launch playbook
  ansible-playbook playbook.yaml --ask-become-pass
}
