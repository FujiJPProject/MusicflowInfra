terraform {
  # backend移行作業中のみ使用する一時的なlocal backend。
  #
  # 新しいState用S3バケットをTerraform自身で作成するため、
  # 一度remote stateをローカルへ退避する。
  backend "local" {
    path = "terraform.tfstate"
  }
}