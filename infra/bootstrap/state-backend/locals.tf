locals {
  # AWS Account ID + Regionを含めることで、
  # S3バケット名が他環境と衝突しにくい形にする。
  state_bucket_name = "${var.project_name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-tfstate"

  # すべてのbootstrapリソースへ付与する共通タグ。
  common_tags = {
    Project     = var.project_name
    Environment = "shared"
    ManagedBy   = "Terraform"
    Purpose     = "TerraformState"
  }
}