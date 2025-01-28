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

module "overlord" {
  source = "./nodes/overloard"
  base_data = {
    base_common = local.base_common,
    profile = var.profile,
    region = var.region,
    cluster_name = var.cluster_name,
    druid_version = var.druid_version,
    key_name = aws_key_pair.kp.key_name,
    ami_id = data.aws_ami.alinux.id,
    sg_id = aws_security_group.druid_sg.id,
    pk_file_path = local.pk_file_path,
  }
}

# module "zk" {
#   source = "./nodes/zk"
#   base_data = {
#     profile = var.profile,
#     region = var.region,
#     cluster_name = var.cluster_name,
#     zk_data = var.zk_data,
#     key_name = aws_key_pair.kp.key_name,
#     ami_id = data.aws_ami.alinux.id,
#     sg_id = aws_security_group.druid_sg.id,
#     access_key = aws_iam_access_key.druid_access_key.id,
#     secret_key = aws_iam_access_key.druid_access_key.secret,
#     pk_file_path = local.pk_file_path,
#   }
# }
