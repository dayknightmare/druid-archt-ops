variable "base_data" {
  type = object({
    profile = string,
    region = string,
    cluster_name = string,
    druid_version = string,
    base_common = string,
    key_name = string,
    ubuntu24_id = string,
    sg_id = string,
    pk_file_path = string,
  })
}