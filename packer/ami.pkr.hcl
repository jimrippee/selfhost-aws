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

variable "region" {
  type    = string
  default = "us-west-1"
}

variable "aws_profile" {
  default = "selfhost-github" # Your named AWS CLI profile
}


source "amazon-ebs" "debian" {
  region                  = var.region
  instance_type           = "t3a.micro"
  ami_name                = "debian12-selfhost-{{timestamp}}"
  ami_description         = "Debian 12 AMI with Docker, Vector, Tailscale, Watchtower, etc."
  ssh_pty                 = true

  source_ami_filter {
    filters = {
      name                = "debian-12-amd64-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["136693071363"]  # Debian official AMIs
    most_recent = true
  }

  ssh_username              = "admin" # or "debian" depending on the AMI
  ssh_keypair_name          = "selfhost-key"
  ssh_private_key_file      = "/Users/rippee/.ssh/selfhost-key"

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 20
    volume_type = "gp3"
    delete_on_termination = true
  }

  iam_instance_profile = "selfhost-ec2-ssm-role" # Assumes this profile exists
  associate_public_ip_address = true
}

build {
  name    = "debian12-with-selfhost-tools"
  sources = ["source.amazon-ebs.debian"]


  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
    extra_arguments = [
      "-e", "ansible_python_interpreter=/usr/bin/python3",
      "-c", "scp"
    ]
}

}
