resource "aws_instance" "base" {
  ami                         = data.aws_ami.ubuntu24.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.kp.key_name

  vpc_security_group_ids = [
    aws_security_group.druid_sg.id
  ]

  user_data = templatefile(
    "./scripts/base/init.sh",
    {
      "base_common" : local.base_common_runtime,
      "druid_version" : var.druid_version,
      "region" : var.region,
      "access_key" : aws_iam_access_key.druid_access_key.id,
      "secret_key" : aws_iam_access_key.druid_access_key.secret,
    }
  )

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
  }

  depends_on = [
    tls_private_key.pk,
    aws_security_group.druid_sg
  ]

  tags = {
    Name         = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-base"
    CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-base"
    ClusterName  = var.cluster_name
    ResourceType = "druid-base"
  }
}

resource "null_resource" "wait_base" {
  depends_on = [aws_instance.base]

  provisioner "remote-exec" {
    inline = [
      file("./scripts/base/wait_user_data.sh"),
      "cat /home/ubuntu/finished.txt",
      "cat /var/log/cloud-init-output.log",
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file(local.pk_file_path)
      host = aws_instance.base.public_ip
    }
  }
}

resource "aws_ami_from_instance" "ami_base" {
  name               = "druid-base"
  source_instance_id = aws_instance.base.id

  depends_on = [null_resource.wait_base]

  tags = {
    Name         = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-base"
    CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-base-ami"
    ClusterName  = var.cluster_name
    ResourceType = "druid-base-ami"
  }
}
