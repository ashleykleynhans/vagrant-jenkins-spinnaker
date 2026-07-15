packer {
  required_plugins {
    utm = {
      version = ">=v0.0.2"
      source  = "github.com/naveenrajm7/utm"
    }
  }
}

variable "os_name" { type = string }
variable "os_version" { type = string }
variable "os_arch" { type = string }
variable "iso_url" { type = string }
variable "iso_checksum" { type = string }
variable "cpus" { type = number }
variable "memory" { type = number }
variable "disk_size" { type = number }
variable "ssh_username" { type = string }
variable "ssh_password" { type = string }
variable "box_name" { type = string }
variable "box_version" { type = string }

source "utm-cloud" "ubuntu" {
  vm_name                = "${var.os_name}-${var.os_version}-${var.os_arch}-${formatdate("YYYYMMDDhhmm", timestamp())}"
  vm_arch                = var.os_arch
  vm_backend             = "qemu"
  iso_url                = var.iso_url
  iso_checksum           = var.iso_checksum
  cpus                   = var.cpus
  memory                 = var.memory
  disk_size              = var.disk_size
  hard_drive_interface   = "nvme"
  uefi_boot              = true
  hypervisor             = true
  use_cd                 = true
  cd_label               = "cidata"
  cd_content = {
    "user-data" = templatefile("${path.root}/http/user-data.pkrtpl", { ssh_username = var.ssh_username, ssh_password = var.ssh_password })
    "meta-data" = file("${path.root}/http/meta-data")
  }
  resize_cloud_image     = true
  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password
  ssh_timeout            = "10m"
  shutdown_command       = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  display_nopause        = true
  boot_nopause           = true
  export_nopause         = true
}

build {
  sources = ["source.utm-cloud.ubuntu"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "${path.root}/scripts/apt-upgrade.sh"
    ]
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S sh -eux '{{ .Path }}'"
    scripts = [
      "${path.root}/scripts/cleanup.sh"
    ]
    environment_vars = [
      "HOME_DIR=/home/${var.ssh_username}"
    ]
  }

  post-processor "utm-vagrant" {
    output               = "${path.root}/../builds/${var.box_name}.box"
    compression_level    = 9
    architecture         = var.os_arch == "aarch64" ? "arm64" : "amd64"
  }
}
