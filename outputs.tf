output "role_arn" {
  description = "IAM role ARN for IRSA"
  value       = aws_iam_role.bedrock_invoke.arn
}

output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.bedrock_invoke.name
}

output "service_account_annotation_key" {
  description = "Kubernetes annotation key for IRSA"
  value       = "eks.amazonaws.com/role-arn"
}

output "service_account_annotation_value" {
  description = "Kubernetes annotation value for IRSA"
  value       = aws_iam_role.bedrock_invoke.arn
}

output "assume_role_policy" {
  description = "Rendered assume role policy JSON"
  value       = data.aws_iam_policy_document.assume.json
}

output "bedrock_policy" {
  description = "Rendered Bedrock policy JSON"
  value       = data.aws_iam_policy_document.bedrock.json
}

