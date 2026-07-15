#!/bin/sh -eux

# Retry helper: runs a command until it succeeds or max attempts reached
retry_apt() {
  local desc="$1"; shift
  local max=30
  for i in $(seq 1 $max); do
    if sudo "$@" 2>&1; then
      return 0
    fi
    echo "  $desc locked (attempt $i/$max), waiting..."
    sleep 10
  done
  echo "ERROR: $desc failed after $max attempts"
  return 1
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

# Update and upgrade with retry
retry_apt "apt update" apt-get -y update
retry_apt "apt dist-upgrade" apt-get -y dist-upgrade -o Dpkg::Options::="--force-confnew"

# Hold networking packages to prevent SSH disruption during this script
# (dist-upgrade may still restart SSH; Packer has expect_disconnect)
