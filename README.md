# vagrant-jenkins-spinnaker

> Supports Spinnaker 2026.2.2 and higher.

Provision Jenkins and Spinnaker for CI/CD using Vagrant and Ansible.

> Supports arm64 on VMware Fusion (Apple Silicon). Uses Ubuntu 26.04 LTS (Resolute Raccoon).

## Requirements

At least the following hardware resources will be required on the host machine:

| VM        | CPU | Memory |
|-----------|-----|--------|
| jenkins   |  2  | 2GB    |
| spinnaker |  2  | 6GB    |
|           |     |        |
| TOTAL     |  4  | 8GB    |

You will also need VMware Fusion (free for personal use) installed on your Mac.

## Clone the GitHub Repository

Run the following command from the terminal to clone the GitHub Repository:

```bash
git clone https://github.com/ashleykleynhans/vagrant-jenkins-spinnaker.git
```

## Install Required Software

Begin by installing the homebrew package manager.

Run the following command from the terminal to install homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

All of the remaining software can be installed by cloning the git repository and
running the setup script provided.

Run the setup script from the terminal to install the required software:

```bash
./setup.sh
```

The setup script installs:

- Vagrant
- Ansible
- Vagrant VMware utility (for VMware Fusion integration)

## Managing the Stack

Begin by ensuring that you are in the directory which the Github Repository was cloned to:

```bash
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

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/vagrant-jenkins-spinnaker)
are welcome. Bug fixes and new features are encouraged.

## Appreciate my work?

<a href="https://www.buymeacoffee.com/ashleyk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
