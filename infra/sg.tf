resource "aws_security_group" "druid_sg" {
  name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-sg"

  tags = {
    Name         = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-sg"
    CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-sg"
    ClusterName  = var.cluster_name
    ResourceType = "druid-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "druid_inbound_internal_ip" {
  security_group_id = aws_security_group.druid_sg.id
  cidr_ipv4         = "172.31.0.0/16"
  ip_protocol       = "-1"
}

data "http" "my_ip" {
 url = "https://ipv4.icanhazip.com"
}

resource "aws_vpc_security_group_ingress_rule" "druid_ex_ip" {
  security_group_id = aws_security_group.druid_sg.id
  cidr_ipv4         = "${chomp(data.http.my_ip.response_body)}/32"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "druid_outbound_all_ipv4" {
  security_group_id = aws_security_group.druid_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "druid_outbound_all_ipv6" {
  security_group_id = aws_security_group.druid_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
