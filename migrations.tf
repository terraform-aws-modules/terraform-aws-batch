################################################################################
# Migrations: v2.x -> v3.0.0
################################################################################

moved {
  from = aws_iam_role_policy_attachment.instance["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  to   = aws_iam_role_policy_attachment.instance["AmazonSSMManagedInstanceCore"]
}

moved {
  from = aws_iam_role_policy_attachment.instance["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"]
  to   = aws_iam_role_policy_attachment.instance["AmazonEC2ContainerServiceforEC2Role"]
}

moved {
  from = aws_iam_role_policy_attachment.spot_fleet["arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"]
  to   = aws_iam_role_policy_attachment.spot_fleet["AmazonEC2SpotFleetTaggingRole"]
}

moved {
  from = aws_iam_role_policy_attachment.service["arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"]
  to   = aws_iam_role_policy_attachment.service["AWSBatchServiceRole"]
}
