terraform {
  # Terraformのstate保存先としてAmazon S3を使用する
  backend "s3" {
    # Step1で作成したTerraform State用S3バケット。
    bucket = "musicflows-infra-725106931660-ap-northeast-1-tfstate"

    # bootstrap自身のstate保存場所。
    key = "bootstrap/state-backend/terraform.tfstate"

    # S3バケットを作成したRegion。
    region = "ap-northeast-1"

    # S3ネイティブのState Lockを有効化する。
    #
    # 複数Terraformプロセスが同じStateを
    # 同時更新して破損させることを防止する。
    use_lockfile = true
  }
}