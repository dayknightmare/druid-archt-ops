# resource "aws_instance" "overlord" {
#     ami = aws_ami_from_instance.ami_base.id
#     instance_type = "m5a.large"
#     associate_public_ip_address = false
#     key_name = aws_key_pair.kp.key_name

#     vpc_security_group_ids = [
#       aws_security_group.druid_sg.id
#     ]

#     user_data = templatefile(
#       "./scripts/overlord/init.sh",
#       {
#         "druid_version": var.druid_version,
#         "overlord_common": local.overlord_common_runtime,
#         "overlord_jvm": local.overlord_jvm,
#         "overlord_daemon": local.overlord_daemon,
#       }
#     )

#     ebs_block_device {
#       device_name = "/dev/sda1"
#       volume_size = 30
#     }

#     tags = {
#       Name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-overlord"
#       CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-overlord"
#       ClusterName = var.cluster_name
#       ResourceType = "druid-overlord"
#     }
# }

# resource "aws_ami_from_instance" "ami-overlord" {
#   name = "druid-overlord"
#   source_instance_id = aws_instance.overlord.id

#   tags = {
#     Name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-overlord"
#     CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-overlord-ami"
#     ClusterName = var.cluster_name
#     ResourceType = "druid-overlord-ami"
#   }
# }