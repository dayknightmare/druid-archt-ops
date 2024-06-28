# resource "aws_instance" "overlord" {
#     ami = data.aws_ami.ubuntu24.id
#     instance_type = "t2.micro"
#     associate_public_ip_address = false
#     # count = 2

#     ebs_block_device {
#       device_name = "/dev/sda1"
#       volume_size = 30
#     }

#     tags = {
#       Name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-overlord"
#       CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-overlord"
#       ClusterName = var.cluster_name
#     }
# }

# resource "aws_ami_from_instance" "ami-overlord" {
#   name               = "druid-overlord"
#   source_instance_id = aws_instance.overlord.id

#   tags = {
#     Name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-overlord"
#     CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-overlord"
#     ClusterName = var.cluster_name
#   }
# }