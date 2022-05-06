# vagrant-jenkins-spinnaker

# NOTE: This is a work in progress, and is currently incomplete

> Supports Spinnaker v1.27.0 and higher, and Halyard v1.45.0 and higher.
Previous versions are not supported since their dependency packages are no longer
available to download after JFrog sunset Bintray on 1st May 2021.

Provision Jenkins and Spinnaker for CI/CD using Vagrant, Virtualbox and Ansible with the following configuration:

* 1 Jenkins box running Ubuntu 18.04 LTS
* 1 Spinnaker box running Ubuntu 22.04 LTS

> The reason for Spinnaker running Ubuntu 22.04 LTS is because the spinnaker-community repos
do not include sizes, and this causes issues when Halyard installs the spinnaker-igor
and spinnaker-clouddriver dependency packages, and Halyard does not complete the
installation process.

## Requirements

At least the following hardware resources will be required on the host machine that will be running the VirtualBox guest VMs:

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

All of the remaining software can be installed by cloning the git repository and  running the setup script provided.

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
