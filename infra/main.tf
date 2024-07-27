terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

data "aws_ami" "ubuntu24" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_s3_bucket" "bucket_dw" {
  bucket = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-datawarehouse"

  tags = {
    CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-s3"
    ClusterName  = var.cluster_name
    ResourceType = "druid-s3"
  }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-key"
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./storage/${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-key.pem"
  }
}

