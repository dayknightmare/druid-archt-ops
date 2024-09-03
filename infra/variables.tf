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
  type = string
  default = "t2.micro"
}


variable "druid_version" {
  type        = string
  description = "Select Apache Druid version to be used in cluster"
  default     = "apache-druid-30.0.0"

  validation {
    condition = contains([
      "apache-druid-30.0.0",
      "apache-druid-29.0.1",
      "apache-druid-29.0.0",
      "apache-druid-28.0.1",
      "apache-druid-28.0.0",
      "apache-druid-27.0.0",
      "apache-druid-26.0.0",
      "apache-druid-25.0.0",
      "apache-druid-24.0.2",
      "apache-druid-24.0.1",
      "apache-druid-24.0.0",
    ], var.druid_version)
    error_message = "Invalid Druid version, please choice a version in https://archive.apache.org/dist/druid that be greater or equal than apache-druid-24.0.0"
  }
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
