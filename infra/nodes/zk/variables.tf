variable "base_data" {
  type = object({
    profile = string,
    region = string,
    cluster_name = string,
    key_name = string,
    ami_id = string,
    sg_id = string,
    pk_file_path = string,
    access_key = string,
    secret_key = string,
    zk_config = object({
      instance = string,
      count    = number,
      version  = string,
    }),
  })
}