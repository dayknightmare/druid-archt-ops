resource "aws_s3_bucket" "bucket_dw" {
  bucket = "${var.druid_config.cluster_name}-druid-datawarehouse"

  tags = {
    CostTracking = "${var.druid_config.cluster_name}-druid-s3"
    ClusterName  = var.druid_config.cluster_name
    ResourceType = "druid-s3"
  }
}
