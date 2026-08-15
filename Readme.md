# 環境構築


## 1. アクセスキーの作成

 - アクセスキーの作成
   - AWS コンソール画面から IAM を選択
   - アクセスキーを発行するユーザーを選択
   - アクセスキーエリアで「アクセスキーを作成」を押下
   - 作成後にアクセスキー、シークレットキーを保存
     - ※シークレットキーは作成時のみ生成可能
   
.awsフォルダの作成
```shell
mkdir -p ~/.aws
sudo chown -R <ユーザー名>:<ユーザー名> /home/twook/.aws
chmod 700 ~/.aws

```

## 2. コンテナのビルド

ディレクトリの移動
```shell
cd ~/music-infra
```

UID/GID設定。
```shell
export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

echo $HOST_UID
echo $HOST_GID
```

Provider cache作成
```shell
mkdir -p .terraform-plugin-cache
```

dockerイメージのビルド
```shell
docker compose build terraform
```

## 3. AWSの接続確認

コンテナの起動
```shell
docker compose run --rm terraform
terraform version
aws --version
```

プロファイルの作成
```shell
aws configure --profile default
```

プロファイルの確認
```shell
cat ~/.aws/config
cat ~/.aws/credentials
```

AWSへの接続確認
```shell
aws sts get-caller-identity
```