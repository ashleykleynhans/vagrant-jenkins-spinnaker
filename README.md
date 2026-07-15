# vagrant-jenkins-spinnaker

Provision Jenkins and Spinnaker for CI/CD using Vagrant and Ansible.

> [!NOTE]
> Supports Spinnaker 2026.2.2 on k3s Kubernetes, arm64 on UTM (Apple Silicon) with Ubuntu 26.04 LTS (Resolute Raccoon).

Spinnaker is deployed as a Kubernetes application on a single-node k3s cluster
using the official [Spinnaker kustomize](https://github.com/spinnaker/spinnaker/tree/main/spinnaker-kustomize)
manifests. This replaces the deprecated Halyard-based installation.

## Requirements

At least the following hardware resources will be required on the host machine:

| VM        | CPU | Memory |
|-----------|-----|--------|
| jenkins   |  2  | 2GB    |
| spinnaker |  6  | 12GB   |
|           |     |        |
| TOTAL     |  8  | 14GB   |

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

The setup script installs: Homebrew, UTM, Vagrant, the vagrant-utm plugin, Packer, QEMU, and Ansible.

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

# Install QEMU (provides qemu-img for cloud image resize)
brew install qemu

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
vagrant box add builds/ashleykleynhans/ubuntu2604-arm64.box --name ashleykleynhans/ubuntu2604-arm64
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

## Architecture

Two VMs are provisioned:

```
┌──────────────────────────────────────────┐
│ Host (Apple Silicon Mac)                 │
│ ┌──────────────┐ ┌────────────────────┐  │
│ │ Jenkins VM   │ │ Spinnaker VM       │  │
│ │ 2GB / 2 CPU  │ │ 12GB / 6 CPU       │  │
│ │              │ │                    │  │
│ │ Jenkins LTS  │ │ ┌───────┐          │  │
│ │ Docker       │ │ │ Minio │          │  │
│ │              │ │ │ (S3)  │          │  │
│ │ → :8080      │ │ └───────┘          │  │
│ └──────────────┘ │                    │  │
│                  │ ┌────────────────┐ │  │
│                  │ │ k3s (1-node)   │ │  │
│                  │ │ • clouddriver  │ │  │
│                  │ │ • deck         │ │  │
│                  │ │ • echo         │ │  │
│                  │ │ • fiat         │ │  │
│                  │ │ • front50      │ │  │
│                  │ │ • gate         │ │  │
│                  │ │ • igor         │ │  │
│                  │ │ • mariadb      │ │  │
│                  │ │ • orca         │ │  │
│                  │ │ • redis        │ │  │
│                  │ │ • rosco        │ │  │
│                  │ │ • Traefik      │ │  │
│                  │ └────────────────┘ │  │
│                  │                    │  │
│                  │ :80  → Deck        │  │
│                  │ :80  → Gate        │  │
│                  │ :9090→ Minio       │  │
│                  └────────────────────┘  │
└──────────────────────────────────────────┘
```

### Services

| Service | Role | Backend |
|---------|------|---------|
| **Jenkins** | CI server | Docker, Git |
| **k3s** | Lightweight Kubernetes | containerd |
| **Spinnaker** | CD platform (9 microservices) | Redis + MariaDB + Minio S3 |
| **MariaDB** | SQL persistence | k3s StatefulSet (mariadb) |
| **Minio** | S3-compatible object store | Docker container, port 9090 |
| **Redis** | In-memory cache/queue | k3s StatefulSet |
| **Traefik** | HTTP ingress controller | Built into k3s |

### Networking

Both VMs share a private network (`10.10.10.0/24`). Spinnaker communicates with
Jenkins via the host-only network. Traefik listens on port 80 on the Spinnaker
VM and routes `/` to Deck and `/api/v1` to Gate.

## Project Layout

```
.
├── Vagrantfile                   # VM definitions (box, provider, memory, IPs)
├── setup.sh                      # Host software installer (Homebrew, UTM, etc.)
├── packer/
│   ├── ubuntu-26.04.pkr.hcl      # Packer template (utm-cloud builder)
│   ├── ubuntu-26.04.auto.pkrvars.hcl  # Build variables (ISO URL, disk size, etc.)
│   ├── http/
│   │   ├── user-data.pkrtpl      # cloud-init: user, SSH keys, packages
│   │   └── meta-data             # cloud-init: instance ID, hostname
│   └── scripts/
│       ├── apt-upgrade.sh        # Provisioner: apt update + dist-upgrade
│       └── cleanup.sh            # Provisioner: guest tools, SSH key, cleanup
└── ansible/
    ├── files/
    │   ├── clouddriver-local.yml   # S3/Minio endpoint for clouddriver
    │   ├── front50-local-k8s.yml   # S3/Minio endpoint for front50
    │   ├── gate-local.yml          # Basic auth for gate
    │   ├── docker.json            # Docker daemon config
    │   └── minio.service          # Minio systemd unit
    ├── playbooks/
    │   ├── group_vars/
    │   │   └── all.yml            # Shared variables (architecture, version)
    │   ├── includes/
    │   │   ├── apt_over_https.yml
    │   │   ├── install_docker.yml
    │   │   ├── install_minio.yml
    │   │   └── install_useful_packages.yml
    │   ├── jenkins.yml            # Jenkins VM playbook
    │   └── spinnaker.yml          # Spinnaker VM playbook (k3s + MySQL + kustomize)
    └── templates/
        └── spinnaker-kustomization.yml.j2  # kustomize overlay template
```

### How it works

1. **`setup.sh`** installs macOS prerequisites: UTM, Vagrant, Packer, QEMU, Ansible
2. **Packer** builds an Ubuntu 26.04 arm64 UTM box from the official cloud image,
   pre-installing UTM guest tools and the Vagrant SSH key
3. **`vagrant box add`** registers the built box locally
4. **`vagrant up`** creates two VMs using the registered box
5. **Ansible** provisions each VM:
   - **Jenkins**: Docker, Jenkins LTS (Java 25), exposes port 8080
   - **Spinnaker**: Docker, Minio (S3), MySQL 8, k3s, then applies Spinnaker
     via `kubectl kustomize` from the official GitHub manifests
6. The kustomize overlay pinpoints image tags to the version in `group_vars/all.yml`,
   configures S3/Minio as the persistent backend, and MySQL for SQL-backed services

### Upgrading Spinnaker

Edit `ansible/playbooks/group_vars/all.yml` and change:

```yaml
spinnaker_version: 2026.2.2
```

Then:

```bash
vagrant provision spinnaker
```

## Accessing Services

Ports are forwarded from the VMs to your host via UTM:

| Service | Host URL | VM Port |
|---------|----------|---------|
| Spinnaker Deck (UI) | http://localhost:9000 | 80 |
| Spinnaker Gate (API) | http://localhost:9000/api/v1 | 80 |
| Jenkins | http://localhost:8080 | 8080 |

Login credentials: `admin` / `admin`

> [!NOTE]
> After `vagrant up`, Spinnaker pods take 5-15 minutes to start (9 JVM services on a single VM).

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
