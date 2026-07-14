# vagrant-jenkins-spinnaker

Provision Jenkins and Spinnaker for CI/CD using Vagrant and Ansible.

> [!NOTE]
> Supports Spinnaker 2026.2.2 and higher, arm64 on UTM (Apple Silicon) with Ubuntu 26.04 LTS (Resolute Raccoon).

## Requirements

At least the following hardware resources will be required on the host machine:

| VM        | CPU | Memory |
|-----------|-----|--------|
| jenkins   |  2  | 2GB    |
| spinnaker |  2  | 6GB    |
|           |     |        |
| TOTAL     |  4  | 8GB    |

## Clone the Repository

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

Before starting the VMs, build the Ubuntu 26.04 base box for UTM.

### GitHub Personal Access Token

> [!IMPORTANT]
> `packer init` downloads the UTM plugin from GitHub, which has a rate limit for unauthenticated requests. If you see a rate-limit error, create a [personal access token](https://github.com/settings/tokens/new) (no scopes needed) and export it:
>
> ```bash
> export PACKER_GITHUB_API_TOKEN="your_token_here"
> ```

### Build

```bash
cd packer
packer init ubuntu-26.04.pkr.hcl
packer build -var-file=ubuntu-26.04.auto.pkrvars.hcl ubuntu-26.04.pkr.hcl
cd ..

# Register the built box with Vagrant
vagrant box add builds/ashleykleynhans-ubuntu2604-arm64.box --name ashleykleynhans/ubuntu2604-arm64
```

#### Build stages

| Stage | What happens | Duration |
|-------|-------------|----------|
| Retrieving ISO | Downloads Ubuntu 26.04 server ISO (~2.9 GB) | 1-5 min |
| Creating virtual machine | UTM creates the VM, mounts ISOs, sets up networking | < 1 min |
| Waiting for boot | VM powers on, UEFI firmware initializes | ~10 seconds |
| Typing boot commands over VNC | Packer sends the autoinstall kernel command line | < 1 min |
| Waiting for SSH | Ubuntu autoinstall runs: partitioning, package install, first reboot | **10-25 min** |
| Connected via SSH | Autoinstall completed, Packer connects and runs provisioner scripts | 1-3 min |
| Post-processor | Packages the VM into a Vagrant box file (`builds/`) | 1-3 min |

> [!TIP]
> The `Waiting for SSH to become available...` stage is the longest and is silent in Packer output. You can watch the installer progress in the UTM app window.

> [!NOTE]
> Total build time: 15-35 minutes depending on internet speed and CPU.

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
