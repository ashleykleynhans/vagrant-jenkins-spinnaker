#!/bin/sh -eux

HOME_DIR="${HOME_DIR:-/home/vagrant}"

# Retry helper: runs a command until it succeeds or max attempts reached
retry_apt() {
  local desc="$1"; shift
  local max=30
  for i in $(seq 1 $max); do
    if sudo "$@" 2>&1; then
      return 0
    fi
    if [ "$i" -eq "$max" ]; then
      echo "ERROR: $desc failed after $max attempts"
      return 1
    fi
    echo "  $desc locked (attempt $i/$max), waiting..."
    sleep 10
  done
}

# Disable interactive apt prompts
echo 'export DEBIAN_FRONTEND=noninteractive' | sudo tee -a /etc/environment

# Disable release upgrades
sudo sed -i 's/^Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades

# Stop and disable apt timers
sudo systemctl stop apt-daily.timer apt-daily-upgrade.timer || true
sudo systemctl disable apt-daily.timer apt-daily-upgrade.timer || true
sudo systemctl mask apt-daily.service apt-daily-upgrade.service || true
sudo systemctl daemon-reload

# Disable periodic apt activities
sudo tee /etc/apt/apt.conf.d/10periodic <<EOF > /dev/null
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

# Update and upgrade with retry (cloud-init may still hold apt lock)
retry_apt "apt update" apt-get -y update
retry_apt "apt dist-upgrade" apt-get -y dist-upgrade -o Dpkg::Options::="--force-confnew"

# Install UTM guest support
sudo apt-get -y install --no-install-recommends spice-vdagent qemu-guest-agent spice-webdavd || true

# Install Vagrant SSH key (runs as vagrant, targets vagrant's home)
mkdir -p "$HOME_DIR/.ssh"
pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub"
if command -v wget >/dev/null 2>&1; then
  wget --no-check-certificate "$pubkey_url" -O "$HOME_DIR/.ssh/authorized_keys"
elif command -v curl >/dev/null 2>&1; then
  curl --insecure --location "$pubkey_url" > "$HOME_DIR/.ssh/authorized_keys"
else
  echo "Cannot download vagrant public key"
  exit 1
fi
chmod -R go-rwsx "$HOME_DIR/.ssh"

# Ensure password-less sudo for vagrant (cloud-init should handle this, but be safe)
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/99_vagrant > /dev/null
sudo chmod 440 /etc/sudoers.d/99_vagrant

# Cleanup
sudo apt-get -y autoremove
sudo apt-get -y clean

# Remove udev persistent rules
sudo rm -rf /etc/udev/rules.d/70-persistent-net.rules || true

# Truncate logs
sudo find /var/log -type f -exec truncate -s 0 {} \;

# Clean temp
sudo rm -rf /tmp/* /var/tmp/*

# Blank machine-id for unique ID on first boot
sudo truncate -s 0 /etc/machine-id
if [ -f /var/lib/dbus/machine-id ] && [ ! -L /var/lib/dbus/machine-id ]; then
  sudo truncate -s 0 /var/lib/dbus/machine-id
fi

# Clear history
sudo rm -f /root/.wget-hsts
export HISTSIZE=0
