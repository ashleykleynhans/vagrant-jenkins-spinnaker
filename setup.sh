#!/usr/bin/env bash

# Install homebrew
echo "Installing homebrew"
which brew
if [[ $? == 0 ]];
then
  echo "Homebrew is already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Vagrant
echo "Installing Vagrant"
brew install vagrant

# Install Ansible
echo "Installing Ansible"
brew install ansible

# Install VMware Fusion Vagrant utility
echo "Installing Vagrant VMware utility"
brew install vagrant-vmware-utility
