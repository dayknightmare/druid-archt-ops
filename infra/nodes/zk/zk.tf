resource "aws_instance" "zk" {
  ami                         = var.base_data.ami_id
  instance_type               = var.base_data.zk_data.instance
  associate_public_ip_address = true
  key_name                    = var.base_data.key_name
  count                       = var.base_data.zk_data.count

  vpc_security_group_ids = [
    var.base_data.sg_id
  ]

  user_data = templatefile(
    "./scripts/zk/init.sh",
    {
      "zk_version" : var.base_data.zk_data.version,
      "zk_id" : count.index,
      "cluster_name" : var.base_data.cluster_name,
      "access_key" : var.base_data.access_key,
      "secret_key" : var.base_data.secret_key,
      "region": var.base_data.region,
    }
  )

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125
    volume_size = 30
  }

  tags = {
    Name         = "${var.base_data.cluster_name}-druid-zk-${count.index}"
    CostTracking = "${var.base_data.cluster_name}-druid-zk"
    ClusterName  = var.base_data.cluster_name
    ResourceType = "druid-zk"
  }
}

resource "null_resource" "wait_zk" {
  for_each = {
    for inst in aws_instance.zk : inst.tags.Name => inst
  }

  depends_on = [aws_instance.zk]

  provisioner "remote-exec" {
    inline = [
      file("./scripts/base/wait_user_data.sh"),
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.base_data.pk_file_path)
      host        = each.value.public_ip
    }
  }
}
