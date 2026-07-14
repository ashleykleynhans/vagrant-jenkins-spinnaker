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

source "utm-iso" "ubuntu" {
  vm_name                = "${var.os_name}-${var.os_version}-${var.os_arch}"
  vm_arch                = var.os_arch
  vm_backend             = "qemu"
  iso_url                = var.iso_url
  iso_checksum           = var.iso_checksum
  iso_interface          = "usb"
  cpus                   = var.cpus
  memory                 = var.memory
  disk_size              = var.disk_size
  hard_drive_interface   = "nvme"
  uefi_boot              = true
  hypervisor             = true
  display_hardware_type  = "virtio-gpu-gl-pci"
  disable_vnc            = false
  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password
  ssh_timeout            = "30m"
  http_directory         = "${path.root}/http"
  boot_wait              = "3s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<enter><wait5>",
    "initrd /casper/initrd<enter><wait5>",
    "boot<enter>"
  ]
  shutdown_command       = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  keep_registered        = true
}

build {
  sources = ["source.utm-iso.ubuntu"]

  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/setup.sh"
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
