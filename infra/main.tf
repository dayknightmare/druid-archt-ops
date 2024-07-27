terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
      }
    }
}

provider "aws" {
  region = var.region
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
    ClusterName = var.cluster_name
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

resource "aws_security_group" "druid_sg" {
  name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-sg"

  tags = {
    Name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-sg"
    CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-sg"
    ClusterName = var.cluster_name
    ResourceType = "druid-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "druid_inbound_internal_ip" {
  security_group_id = aws_security_group.druid_sg.id
  cidr_ipv4 = "172.31.0.0/16"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "druid_ex_ip" {
  security_group_id = aws_security_group.druid_sg.id
  cidr_ipv4 = "177.34.189.13/32"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "druid_outbound_all_ipv4" {
  security_group_id = aws_security_group.druid_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "druid_outbound_all_ipv6" {
  security_group_id = aws_security_group.druid_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
