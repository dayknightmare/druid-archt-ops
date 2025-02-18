resource "aws_instance" "overlord" {
  ami                         = var.base_data.ami_id
  instance_type               = var.base_data.overlord_config.instance
  associate_public_ip_address = true
  key_name                    = var.base_data.key_name
  count                       = var.base_data.overlord_config.count

  vpc_security_group_ids = [
    var.base_data.sg_id
  ]

  user_data = templatefile(
    "./scripts/overlord/init.sh",
    {
      "base_common" : var.base_data.base_common,
      "druid_version" : var.base_data.druid_version.druid_version,
      "overlord_common" : local.overlord_common_runtime,
      "overlord_jvm" : local.overlord_jvm,
      "overlord_daemon" : local.overlord_daemon,
    }
  )

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp3"
    volume_size = 30
    iops = 3000
    throughput = 125
  }

  tags = {
    Name         = "${var.base_data.druid_config.cluster_name}-druid-overlord"
    CostTracking = "${var.base_data.druid_config.cluster_name}-druid-overlord"
    ClusterName  = var.base_data.druid_config.cluster_name
    ResourceType = "druid-overlord"
  }
}

resource "null_resource" "wait_overlord" {
  depends_on = [aws_instance.overlord]

  provisioner "remote-exec" {
    inline = [
      file("./scripts/base/wait_user_data.sh"),
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.base_data.pk_file_path)
      host        = aws_instance.overlord.public_ip
    }
  }
}

resource "aws_ami_from_instance" "ami-overlord" {
  name               = "druid-overlord"
  source_instance_id = aws_instance.overlord.id

  depends_on = [null_resource.wait_overlord]

  tags = {
    Name         = "${var.base_data.druid_config.cluster_name}-druid-overlord"
    CostTracking = "${var.base_data.druid_config.cluster_name}-druid-overlord-ami"
    ClusterName  = var.base_data.druid_config.cluster_name
    ResourceType = "druid-overlord-ami"
  }
}
