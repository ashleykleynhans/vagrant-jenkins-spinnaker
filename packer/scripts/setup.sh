#!/bin/sh -eux

HOME_DIR="${HOME_DIR:-/home/vagrant}"

# Disable interactive apt prompts
export DEBIAN_FRONTEND=noninteractive

# Disable release upgrades
sed -i 's/^Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades

# Stop and disable apt timers
systemctl stop apt-daily.timer apt-daily-upgrade.timer || true
systemctl disable apt-daily.timer apt-daily-upgrade.timer || true
systemctl mask apt-daily.service apt-daily-upgrade.service || true
systemctl daemon-reload

# Disable periodic apt activities
cat > /etc/apt/apt.conf.d/10periodic <<EOF
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

# Update and upgrade
apt-get -y update
apt-get -y dist-upgrade -o Dpkg::Options::="--force-confnew"

# Install UTM guest support
apt-get -y install --no-install-recommends spice-vdagent qemu-guest-agent spice-webdavd || true

# Install Vagrant SSH key
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

chown -R vagrant "$HOME_DIR/.ssh"
chmod -R go-rwsx "$HOME_DIR/.ssh"

# Ensure password-less sudo for vagrant
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99_vagrant
chmod 440 /etc/sudoers.d/99_vagrant

# Cleanup
apt-get -y autoremove
apt-get -y clean

# Remove udev persistent rules
rm -rf /etc/udev/rules.d/70-persistent-net.rules || true

# Truncate logs
find /var/log -type f -exec truncate -s 0 {} \;

# Clean temp
rm -rf /tmp/* /var/tmp/*

# Blank machine-id for unique ID on first boot
truncate -s 0 /etc/machine-id
if [ -f /var/lib/dbus/machine-id ] && [ ! -L /var/lib/dbus/machine-id ]; then
  truncate -s 0 /var/lib/dbus/machine-id
fi

# Clear history
rm -f /root/.wget-hsts
export HISTSIZE=0
