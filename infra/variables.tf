variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "cluster_name" {
  description = "Druid cluster name"
  type        = string
}

variable "base_instance_type" {
  description = "Base ec2 instance"
  type        = string
  default     = "t2.micro"
}

variable "druid_version" {
  type        = string
  description = "Select Apache Druid version to be used in cluster"
  default     = "30.0.0"
}

variable "db_type" {
  type        = string
  description = "Select database type between postgres and mysql"
  default     = "mysql"

  validation {
    condition     = contains(["postgres", "mysql"], var.db_type)
    error_message = "Valid values for db_type are (postgres, mysql)."
  }
}

variable "db_host" {
  type        = string
  description = "Database host"
}

variable "db_port" {
  type        = number
  description = "Database port"
}

variable "db_db" {
  type        = string
  description = "Database name"
}

variable "db_user" {
  type        = string
  description = "Database user"
}

variable "db_password" {
  type        = string
  description = "Database password"
}

variable "admin_password" {
  type        = string
  description = "Druid admin password"
}

variable "internal_password" {
  type        = string
  description = "Druid internal system password"
}

variable "zk_data" {
  type = object({
    instance = string,
    count    = number,
    version  = string,
  })

  validation {
    condition     = var.zk_data.count >= 3 && var.zk_data.count % 2 == 1
    error_message = "Instance count must be greater than or equal to 3 and be odd"
  }
}
