resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-key"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_sensitive_file" "kp_file" {
  filename = local.pk_file_path
  file_permission = 400
  directory_permission = 700
  content = tls_private_key.pk.private_key_pem
}
