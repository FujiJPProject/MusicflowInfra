terraform {
  # 使用するTerraform本体のバージョンを固定する。。
  required_version = "= 1.15.8"

  required_providers {
    aws = {
      # AWSリソースを操作する公式HashiCorp AWS Providerを使用する。
      source = "hashicorp/aws"

      # 今回の設計資料で基準としているバージョン。
      # provider更新は別途検証してから行う。
      version = "= 6.55.0"
    }
  }
}