data "aws_ec2_instance_type" "overloard_resource" {
  instance_type = "m5a.xlarge"
}

resource "null_resource" "ff_res" {
  provisioner "local-exec" {
    command = <<-EOT
        echo ${data.aws_ec2_instance_type.overloard_resource.default_vcpus} >> 'cc.txt'
        echo ${data.aws_ec2_instance_type.overloard_resource.memory_size} >> 'cc.txt'
    EOT
  }
}