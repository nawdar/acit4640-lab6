# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu" {
  ami_name      = "web-nginx-aws-v2"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # First, create the directory where files will be uploaded
  provisioner "shell" {
    inline = [
      "echo creating directories",
      "sudo mkdir -p /web/html",
      "sudo chown -R ubuntu:ubuntu /web/html",
      "sudo mkdir -p /tmp/web",
      "sudo chown -R ubuntu:ubuntu /tmp/web"
    ]
  }

  # Then upload the files (after directory exists)
  provisioner "file" {
    source      = "files/index.html"
    destination = "/web/html/index.html"
  }

  provisioner "file" {
    source      = "files/nginx.conf"
    destination = "/tmp/web/nginx.conf"
  }

  provisioner "shell" {
    script = "scripts/install-nginx"
  }

  provisioner "shell" {
    script = "scripts/setup-nginx"
  }
}
