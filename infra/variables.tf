variable "profile" {
  description = "AWS profile"
  type = string
  default = "default"
}

variable "region" {
  description = "AWS region"
  type = string
  default = "us-east-2"
}

variable "cluster_name" {
  description = "Druid cluster name"
  type = string
}

variable "db_type" {
  type = string
  description = "Select database type between postgres and mysql"
  default = "mysql"

  validation {
    condition = contains(["postgres", "mysql"], var.db_type)
    error_message = "Valid values for db_type are (postgres, mysql)."
  }
}

locals {
  envs = {
    for tuple in regexall("(.*)=(.*)", file(".env")) : tuple[0] => sensitive(tuple[1])
  }

  base_db = templatefile(
    var.db_type == "mysql" ? "./conf/base/mysql.properties" : "./conf/base/postgres.properties",
    {
      "db_host": local.envs["DB_HOST"],
      "db_port": local.envs["DB_PORT"],
      "db_db": local.envs["DB_DB"],
      "db_user": local.envs["DB_USER"],
      "db_password": local.envs["DB_PASSWORD"],
    }
  )

  base_common_runtime = templatefile(
    "./conf/base/common.runtime.properties",
    {
      "database_type_ext": var.db_type == "mysql" ? "mysql-metadata-storage" : "postgresql-metadata-storage"
      "db_properties": local.base_db,
      "cluster_name": var.cluster_name,
      "aws_access": local.envs["AWS_SECRET_KEY"],
      "aws_secret": local.envs["AWS_ACCESS_KEY"],
      "admin_password": local.envs["ADMIN_PASSWORD"],
      "internal_password": local.envs["INTERNAL_PASSWORD"],
    }
  )
}