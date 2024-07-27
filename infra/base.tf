resource "aws_instance" "base" {
  ami                         = data.aws_ami.ubuntu24.id
  instance_type               = "t2.micro"
  associate_public_ip_address = false
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
  provisioner "local-exec" {
    command = <<-EOT
      while true; do
        PARAMETER_VALUE=$(aws ssm get-parameter --profile=${var.profile} --name "UserDataBaseCompletion" --query "Parameter.Value" --output text --region ${var.region})
        if [ "$PARAMETER_VALUE" == "completed" ]; then
          break
        fi
        sleep 15
      done
    EOT
  }

  depends_on = [aws_instance.base]
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
