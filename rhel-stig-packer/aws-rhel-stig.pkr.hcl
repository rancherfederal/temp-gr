packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  ami_basename      = var.stig_enable ? "rhel-rke2-stig" : "rhel-rke2"
  ami_basename_fips = var.fips_enable ? "${local.ami_basename}-fips" : local.ami_basename
  ami_name          = var.ami_name == "" ? local.ami_basename_fips : var.ami_name
}

source "amazon-ebs" "rhel_base" {
  ami_name                    = "${local.ami_name}-{{ timestamp }}"
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  ebs_optimized               = true
  instance_type               = var.instance_type
  region                      = var.aws_region
  ssh_username                = "ec2-user"
  subnet_id                   = var.subnet_id
  user_data_file              = "${path.root}/files/cloud-config.yaml"
  vpc_id                      = var.vpc_id

  # /
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "30"
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_id
  }

  # /home
  launch_block_device_mappings {
    device_name           = "/dev/sdb"
    volume_size           = "10"
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_id
  }

  # /var/log /var/log/audit
  launch_block_device_mappings {
    device_name           = "/dev/sdc"
    volume_size           = "15"
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_id
  }

  # /tmp /var /var/tmp
  launch_block_device_mappings {
    device_name           = "/dev/sdd"
    volume_size           = "21"
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_id
  }

  # /var/lib/kubelet /var/lib/rancher
  launch_block_device_mappings {
    device_name           = "/dev/sde"
    volume_size           = "300"
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_id
  }

  source_ami_filter {
    filters = {
      name                = "RHEL-${var.rhel_version}*"
      architecture        = "x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["219670896067"]
  }
}

build {
  name = "rhel-rke2"
  sources = [
    "source.amazon-ebs.rhel_base"
  ]

  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done"]
  }

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    script          = "${path.root}/scripts/volumes.sh"
  }

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    script          = "${path.root}/scripts/stig.sh"

    env = {
      "STIG_ENABLE" = var.stig_enable ? "1" : ""
      "FIPS_ENABLE" = var.fips_enable ? "1" : ""
    }
  }

  provisioner "shell" {
    inline            = ["sudo reboot"]
    expect_disconnect = true
  }



  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"
    remote_folder   = "/run/user/1000"
    script          = "${path.root}/scripts/fix-fstab.sh"
  }
}
