locals {
  pk_file_path = "./storage/${var.druid_config.cluster_name}-druid-key.pem"

  base_db = templatefile(
    var.druid_config.type == "mysql" ? "./conf/base/mysql.properties" : "./conf/base/postgres.properties",
    {
      "db_host" : var.druid_config.host,
      "db_port" : var.druid_config.port,
      "db_db" : var.druid_config.db,
      "db_user" : var.druid_config.user,
      "db_password" : var.druid_config.password,
    }
  )

  base_common = templatefile(
    "./scripts/base/init.sh",
    {
      "base_common" : templatefile(
        "./conf/base/common.runtime.properties",
        {
          "database_type_ext" : var.druid_config.type == "mysql" ? "mysql-metadata-storage" : "postgresql-metadata-storage"
          "db_properties" : local.base_db,
          "cluster_name" : var.druid_config.cluster_name,
          "aws_access" : aws_iam_access_key.druid_access_key.id,
          "aws_secret" : aws_iam_access_key.druid_access_key.secret,
          "admin_password" : var.druid_config.admin_password,
          "internal_password" : var.druid_config.internal_password,
          "env_zk": "\\$${env:DRUID_IPS_ZK:-localhost}",
          "region": var.region,
        }
      ),
      "log4j": file("./conf/base/log4j2.xml"),
      "cluster_name": var.druid_config.cluster_name,
      "druid_version" : var.druid_config.version,
      "region" : var.region,
      "access_key" : aws_iam_access_key.druid_access_key.id,
      "secret_key" : aws_iam_access_key.druid_access_key.secret,
    }
  )
}
