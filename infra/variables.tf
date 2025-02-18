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

variable "zk_config" {
  type = object({
    instance = string,
    count    = number,
    version  = string,
  })

  validation {
    condition     = var.zk_config.count >= 3 && var.zk_config.count % 2 == 1
    error_message = "Instance count must be greater than or equal to 3 and be odd"
  }
}

variable "druid_config" {
  type = object({
    version           = string,
    cluster_name      = number,
    admin_password    = string,
    internal_password = string,
    metadata_config = object({
      type     = string,
      host     = string,
      db       = string,
      user     = string,
      password = string,
      port     = number,
    }),
    overlord_config = object({
      count    = number,
      instance = string,
    }),
  })
}
