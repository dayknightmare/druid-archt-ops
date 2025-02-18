variable "base_data" {
  type = object({
    profile      = string,
    region       = string,
    base_common  = string,
    key_name     = string,
    ami_id       = string,
    sg_id        = string,
    pk_file_path = string,
    druid_config = object({
      cluster_name  = string,
      druid_version = string,
    })
    overlord_config = object({
      count    = number,
      instance = string
    })
  })
}
