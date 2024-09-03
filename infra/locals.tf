
locals {
  pk_file_path = "./storage/${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-key.pem"

  base_db = templatefile(
    var.db_type == "mysql" ? "./conf/base/mysql.properties" : "./conf/base/postgres.properties",
    {
      "db_host" : var.db_host,
      "db_port" : var.db_port,
      "db_db" : var.db_db,
      "db_user" : var.db_user,
      "db_password" : var.db_password,
    }
  )

  overlord_common_runtime = file("./conf/overlord/runtime.properties")
  overlord_jvm = templatefile(
    "./conf/overlord/jvm.config",
    {
      "xms" : "1g"
      "xmx" : "1g",
      "region" : var.region,
    }
  )

  overlord_daemon = templatefile(
    "./conf/overlord/druid.service",
    {
      "cmd_druid" : "./start-cluster-master-with-zk-server"
      "druid_version" : var.druid_version
    }
  )
}
