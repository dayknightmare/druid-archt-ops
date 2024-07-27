resource "aws_iam_user" "druid_iam_user" {
  name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-usr"
}

resource "aws_iam_access_key" "druid_access_key" {
  user = aws_iam_user.druid_iam_user.name

  provisioner "local-exec" {
    command = <<-EOT
        echo access_key: ${aws_iam_access_key.druid_access_key.id} >> ./storage/${var.cluster_name}-config.txt
        echo secret_key: ${aws_iam_access_key.druid_access_key.secret} >> ./storage/${var.cluster_name}-config.txt
    EOT
  }
}

resource "aws_iam_group" "druid_group" {
  name = "${var.cluster_name == "" ? "" : "${var.cluster_name}-"}druid-usr-gr"
}

resource "aws_iam_group_membership" "druid_group_membership" {
  name  = aws_iam_user.druid_iam_user.name
  users = [aws_iam_user.druid_iam_user.name]
  group = aws_iam_group.druid_group.name
}

resource "aws_iam_policy" "druid_group_policy" {
  name   = "druid_policy"
  policy = file("./conf/iam/permissions.json")
}

resource "aws_iam_group_policy_attachment" "druid_group_policy_att" {
  policy_arn = aws_iam_policy.druid_group_policy.arn
  group      = aws_iam_group.druid_group.name
}
