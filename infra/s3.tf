resource "aws_s3_bucket" "bucket_dw" {
  bucket = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-datawarehouse"

  tags = {
    CostTracking = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-s3"
    ClusterName  = var.cluster_name
    ResourceType = "druid-s3"
  }
}
