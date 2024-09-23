locals {
  overlord_common_runtime = file("./conf/overlord/runtime.properties")

  overlord_jvm = templatefile(
    "./conf/overlord/jvm.config",
    {
      "xms" : "1g"
      "xmx" : "1g",
      "region" : var.base_data.region,
    }
  )

  overlord_daemon = templatefile(
    "./conf/overlord/druid.service",
    {
      "cmd_druid" : "./start-cluster-master-with-zk-server"
      "druid_version" : var.base_data.druid_version
    }
  )
}