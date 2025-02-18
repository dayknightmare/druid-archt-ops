data "aws_ec2_instance_type" "overlord_resource" {
  instance_type = var.base_data.overlord_config.instance
}