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

# Install UTM (free virtualization for macOS)
echo "Installing UTM"
brew install --cask utm

# Install Vagrant
echo "Installing Vagrant"
brew install vagrant

# Install the vagrant-utm plugin
echo "Installing Vagrant UTM plugin"
vagrant plugin install vagrant_utm

# Install Packer (for building the base box)
echo "Installing Packer"
brew tap hashicorp/tap
brew install hashicorp/tap/packer

# Install Ansible
echo "Installing Ansible"
brew install ansible
