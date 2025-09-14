packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.0.0"
    }
  }
}

variable "aws_region" {
  default = "us-west-1"
}

variable "ssh_keypair_name" {
  default = "selfhost-key"
}

variable "private_key_file" {
  default = "/Users/rippee/.ssh/selfhost-key"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  default     = "selfhost-github"
}


source "amazon-ebs" "debian" {
  ami_name                    = "debian12-with-selfhost-tools-{{timestamp}}"
  instance_type               = "t3a.small"
  profile                     = var.aws_profile
  region                      = var.aws_region
  ssh_username                = "admin"
  ssh_keypair_name            = var.ssh_keypair_name
  ssh_private_key_file        = var.private_key_file
  ssh_interface               = "public_ip"
  ssh_pty                     = true
  associate_public_ip_address = true
  iam_instance_profile        = "selfhost-ec2-ssm-role"

  source_ami_filter {
    filters = {
      name                = "debian-12-amd64-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["136693071363"]
    most_recent = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 16
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "debian12-with-selfhost-tools"
    Environment = "selfhost"
  }
}

build {
  sources = ["source.amazon-ebs.debian"]

#https://github.com/ansible/workshops/blob/devel/provisioner/packer/automationhub.pkr.hcl
provisioner "ansible" {
  command = "ansible-playbook"
  playbook_file = "./ansible/playbook.yml"
  user = "admin"
  inventory_file_template = "hub ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }}\n"
  use_proxy = false
  }
}


