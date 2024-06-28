resource "aws_instance" "base" {
    ami = data.aws_ami.ubuntu24.id
    instance_type = "t2.micro"
    associate_public_ip_address = false

    user_data = templatefile(
      "./scripts/base/init.sh",
      {
        "base_common": local.base_common_runtime
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
    }
}

resource "aws_ami_from_instance" "ami_base" {
  name               = "druid-base"
  source_instance_id = aws_instance.base

  tags = {
    Name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-base"
    CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-base"
    ClusterName = var.cluster_name
  }
}
