resource "aws_instance" "base" {
    ami = data.aws_ami.ubuntu24.id
    instance_type = "t2.micro"
    associate_public_ip_address = false
    key_name = aws_key_pair.kp.key_name

    vpc_security_group_ids = [
      aws_security_group.druid_sg.id
    ]

    user_data = templatefile(
      "./scripts/base/init.sh",
      {
        "base_common": local.base_common_runtime,
        "druid_version": var.druid_version
      }
    )

    ebs_block_device {
      device_name = "/dev/sda1"
      volume_size = 30
    }

    tags = {
      Name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-base"
      CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-base"
      ClusterName = var.cluster_name
      ResourceType = "druid-base"
    }
}

resource "aws_ami_from_instance" "ami_base" {
  name               = "druid-base"
  source_instance_id = aws_instance.base.id

  tags = {
    Name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-base"
    CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-base-ami"
    ClusterName = var.cluster_name
    ResourceType = "druid-base-ami"
  }
}
