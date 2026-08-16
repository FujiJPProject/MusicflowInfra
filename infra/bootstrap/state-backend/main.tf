# 現在Terraformを実行しているAWSアカウント情報を取得する。
data "aws_caller_identity" "current" {}


# ============================================================
# Terraform State保存用S3バケット
# ============================================================

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.state_bucket_name

  # state bucketは最重要リソースなのでterraform destroy時に削除されないようにfalseとする。
  force_destroy = false

  lifecycle {
    # terraform destroy等による事故でstate bucket自体を削除しないよう保護する。
    # 本当に削除する場合は、この設定を意図的に外してから実行する。
    prevent_destroy = true
  }
}


# ============================================================
# Versioning
# ============================================================

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    # terraform.tfstateが更新されるたび、古いバージョンをS3側へ残す。
    # stateを誤って変更・削除した場合の復旧手段として使用するため。
    status = "Enabled"
  }
}


# ============================================================
# Server Side Encryption
# ============================================================
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      # 初期構成では追加のKMS費用・管理を避け、
      # S3管理キーによるSSE-S3を使用する。
      sse_algorithm = "AES256"
    }
  }
}


# ============================================================
# Public Access Block
# 外部に公開する必要がないS3バケットなので、Publicアクセスを禁止する。
# ============================================================

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  # Public ACLによる公開を禁止。
  block_public_acls = true

  # Public Policyによる公開を禁止。
  block_public_policy = true

  # 既存Public ACLも無視する。
  ignore_public_acls = true

  # Publicと判断されるBucket Policyを制限する。
  restrict_public_buckets = true
}


# ============================================================
# Object Ownership
# ============================================================

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    # ACLを無効化し、IAM Policy / Bucket Policy中心のアクセス管理へ統一する。
    object_ownership = "BucketOwnerEnforced"
  }
}