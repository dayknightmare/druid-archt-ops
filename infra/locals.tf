
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

  base_common = templatefile(
    "./scripts/base/init.sh",
    {
      "base_common" : templatefile(
        "./conf/base/common.runtime.properties",
        {
          "database_type_ext" : var.db_type == "mysql" ? "mysql-metadata-storage" : "postgresql-metadata-storage"
          "db_properties" : local.base_db,
          "cluster_name" : var.cluster_name,
          "aws_access" : aws_iam_access_key.druid_access_key.id,
          "aws_secret" : aws_iam_access_key.druid_access_key.secret,
          "admin_password" : var.admin_password,
          "internal_password" : var.internal_password,
        }
      ),
      "druid_version" : var.druid_version,
      "region" : var.region,
      "access_key" : aws_iam_access_key.druid_access_key.id,
      "secret_key" : aws_iam_access_key.druid_access_key.secret,
    }
  )
}
