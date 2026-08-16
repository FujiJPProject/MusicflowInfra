output "state_bucket_name" {
  description = "Terraform State保存用S3バケット名。"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "Terraform State保存用S3バケットARN。"
  value       = aws_s3_bucket.terraform_state.arn
}

output "aws_account_id" {
  description = "Terraformを実行しているAWS Account ID。"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "State Bucketを作成したAWS Region。"
  value       = var.aws_region
}