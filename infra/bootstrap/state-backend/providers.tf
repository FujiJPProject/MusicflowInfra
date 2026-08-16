provider "aws" {
  # AWS Providerが操作するリージョン。
  region = var.aws_region

  # このProvider経由で作成するリソースへ
  # 共通タグを自動的に付与する。
  default_tags {
    tags = local.common_tags
  }
}