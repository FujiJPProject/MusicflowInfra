variable "project_name" {
  description = "プロジェクト名。S3バケット名やタグの生成に使用する。"
  type        = string

  # S3バケット名として利用しやすいよう、
  # 小文字英数字とハイフンだけに制限する。
  validation {
    condition = (
      can(regex("^[a-z0-9-]+$", var.project_name)) &&
      length(var.project_name) <= 20
    )

    error_message = "project_nameは20文字以内の小文字英数字・ハイフンで指定してください。"
  }
}

variable "aws_region" {
  description = "AWSリソースを作成するリージョン。"
  type        = string
  default     = "ap-northeast-1"
}