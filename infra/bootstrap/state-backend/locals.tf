locals {
  # S3 bucket名はAWS Account IDに依存させず、
  # random_idで生成したsuffixを付与して一意性を確保する。
  state_bucket_name = "${var.project_name}-${var.aws_region}-tfstate-${random_id.state_bucket_suffix.hex}"

  # すべてのbootstrapリソースへ付与する共通タグ。
  common_tags = {
    Project     = var.project_name
    Environment = "shared"
    ManagedBy   = "Terraform"
    Purpose     = "TerraformState"
  }
}