# vagrant-jenkins-spinnaker

> Supports Spinnaker v1.28.1 and higher, and Halyard v1.49.0 and higher.

Provision Jenkins and Spinnaker for CI/CD using Vagrant, Virtualbox and
Ansible.

## Requirements

At least the following hardware resources will be required on the host machine that will
be running the VirtualBox guest VMs:

| VM        | CPU | Memory |
|-----------|-----|--------|
| jenkins   |  2  | 2GB    |
| spinnaker |  2  | 6GB    |
|           |     |        |
| TOTAL     |  4  | 8GB    |

## Clone the GitHub Repository

Run the following command from the terminal to clone the GitHub Repository:

```bash
git clone https://github.com/ashleykleynhans/vagrant-jenkins-spinnaker.git
```

## Install Required Software

Begin by installing the homebrew package manager, which works on both Mac
 and Ubuntu Linux.  May work on other Linux distributions but has not bee
n tested.

Run the following command from the terminal to install homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

All of the remaining software can be installed by cloning the git repository and
running the setup script provided.

Run the setup script from the terminal to install the required software:

```bassh
./setup.sh
```

## Managing the Stack

Begin by ensuring that you are in the directory which the Github Repository was cloned to:

```
cd vagrant-jenkins-spinnaker
```

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
