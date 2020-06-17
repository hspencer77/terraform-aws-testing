
output "policy_document" {
  value = data.aws_iam_policy_document.policy_example.json
}

output "logs_policy_document" {
  value = data.aws_iam_policy_document.logs_kms_access_policy.json
}

output "default_subnet_ids" {
  value = data.aws_subnet_ids.default.ids
}
