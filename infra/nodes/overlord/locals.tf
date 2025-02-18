locals {
  overlord_common_runtime = file("./conf/overlord/runtime.properties")

  overlord_jvm = templatefile(
    "./conf/overlord/jvm.config",
    {
      "xms" : "${floor((data.aws_ec2_instance_type.overlord_resource.memory_size * 0.95) * 1024 * 0.65)}m",
      "xmx" : "${floor((data.aws_ec2_instance_type.overlord_resource.memory_size * 0.95) * 1024 * 0.65)}m",
      "region" : var.base_data.region,
    }
  )

  overlord_daemon = templatefile(
    "./conf/overlord/druid.service",
    {
      "cmd_druid" : "./start-cluster-master-no-zk-server",
    }
  )
}