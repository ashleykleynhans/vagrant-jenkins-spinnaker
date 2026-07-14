# vagrant-jenkins-spinnaker

> Supports Spinnaker 2026.2.2 and higher.

Provision Jenkins and Spinnaker for CI/CD using Vagrant and Ansible.

> Supports arm64 on UTM (Apple Silicon). Uses Ubuntu 26.04 LTS (Resolute Raccoon).

## Requirements

At least the following hardware resources will be required on the host machine:

| VM        | CPU | Memory |
|-----------|-----|--------|
| jenkins   |  2  | 2GB    |
| spinnaker |  2  | 6GB    |
|           |     |        |
| TOTAL     |  4  | 8GB    |

## Clone the GitHub Repository

```bash
git clone https://github.com/ashleykleynhans/vagrant-jenkins-spinnaker.git
cd vagrant-jenkins-spinnaker
```

## Install Required Software

### Option 1: Automated setup

```bash
./setup.sh
```

The setup script installs: Homebrew, UTM, Vagrant, the vagrant-utm plugin, Packer, and Ansible.

### Option 2: Manual setup

```bash
# Install UTM
brew install --cask utm

# Install Vagrant and the UTM plugin
brew install vagrant
vagrant plugin install vagrant_utm

# Install Packer
brew tap hashicorp/tap
brew install hashicorp/tap/packer

# Install Ansible
brew install ansible
```

## Build the Base Box

Before starting the VMs, build the Ubuntu 26.04 base box for UTM:

```bash
cd packer
packer init ubuntu-26.04.pkr.hcl
packer build -var-file=ubuntu-26.04.auto.pkrvars.hcl ubuntu-26.04.pkr.hcl
cd ..

# Register the built box with Vagrant
vagrant box add builds/ashleykleynhans-ubuntu2604-arm64.box --name ashleykleynhans/ubuntu2604-arm64
```

> Building the box downloads the Ubuntu 26.04 server ISO (~2.5 GB) and takes 15-30 minutes
> depending on your internet connection and CPU.

## Managing the Stack

### Starting the Stack

```bash
vagrant up
```

### Stopping the Stack

```bash
vagrant halt
```

### Deleting the Stack

```bash
vagrant destroy -f
```

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/vagrant-jenkins-spinnaker)
are welcome. Bug fixes and new features are encouraged.

## Appreciate my work?

<a href="https://www.buymeacoffee.com/ashleyk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
