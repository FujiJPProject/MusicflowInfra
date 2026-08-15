# ============================================================
# ベースOS
# ============================================================

# 軽量なDebian 12(Bookworm)をTerraform実行環境のベースとして使用する
FROM debian:bookworm-slim


# ============================================================
# Build Arguments 
# イメージ完成後は残さないBuild時専用の変数
# ============================================================

# インストールするTerraformのバージョン
# Terraformは環境差異を防ぐため固定する
ARG TERRAFORM_VERSION=1.15.8

# インストールするAWS CLI v2のバージョン
# latestではなく固定することでDocker Imageの再現性を高める
ARG AWS_CLI_VERSION=2.36.23

# ホストOSのユーザーID
# bind mountしたファイルがroot所有になるのを防ぐため使用する
ARG HOST_UID=1000

# ホストOSのグループID
# bind mountしたファイルのgroupをホスト側と合わせるため使用する
ARG HOST_GID=1000

# aptを対話なしで実行するためのBuild時専用設定
ARG DEBIAN_FRONTEND=noninteractive


# ============================================================
# 基本ツールのインストール
# ============================================================

RUN set -eux; \
    \
    # Debianのパッケージ一覧を最新化する
    apt-get update; \
    \
    # Terraform/AWS CLIの導入・Terraform作業で使用する最低限のツールをインストールする
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        groff \
        jq \
        unzip; \
    \
    # aptのパッケージ一覧を削除してDocker Imageサイズを削減する
    rm -rf /var/lib/apt/lists/*


# ============================================================
# Terraformのインストール
# ============================================================

RUN set -eux; \
    \
    # Debianが認識しているCPUアーキテクチャを取得する
    HOST_ARCH="$(dpkg --print-architecture)"; \
    \
    # Terraformが対応するarchitectureだけ許可する
    case "${HOST_ARCH}" in amd64|arm64) TF_ARCH="${HOST_ARCH}" ;; *) \
         \
            echo "Unsupported architecture for Terraform: ${HOST_ARCH}" >&2; \
            exit 1 \
            ;; \
    esac; \
    \
    # ダウンロードするTerraform ZIPファイル名を作成する
    TF_ZIP="terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip"; \
    \
    # HashiCorp公式サイトからTerraform本体をダウンロードする
    # --retryを指定し、一時的なネットワーク障害では再試行する
    curl \
        --retry 3 \
        --retry-all-errors \
        -fsSLo "/tmp/${TF_ZIP}" \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TF_ZIP}"; \
    \
    # Terraform公式のSHA256チェックサム一覧をダウンロードする
    # ダウンロードしたZIPが改ざんされていないことを確認するために使用する
    curl \
        --retry 3 \
        --retry-all-errors \
        -fsSLo /tmp/terraform_SHA256SUMS \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS"; \
    \
    # 今回ダウンロードしたLinux向けZIPのチェックサムだけを抽出する
    grep " ${TF_ZIP}$" \
        /tmp/terraform_SHA256SUMS \
        > /tmp/terraform_SHA256SUMS.filtered; \
    \
    # SHA256チェックを実行するため一時ディレクトリへ移動する
    cd /tmp; \
    \
    # Terraform ZIPがHashiCorp公開のSHA256値と一致することを確認する
    sha256sum -c terraform_SHA256SUMS.filtered; \
    \
    # Terraform実行ファイルを/usr/local/binへ展開する
    unzip "/tmp/${TF_ZIP}" -d /usr/local/bin; \
    \
    # Terraformバイナリへ実行権限を付与する
    chmod 0755 /usr/local/bin/terraform; \
    \
    # インストールに使用した一時ファイルを削除してImageサイズを抑える
    rm -f \
        "/tmp/${TF_ZIP}" \
        /tmp/terraform_SHA256SUMS \
        /tmp/terraform_SHA256SUMS.filtered


# ============================================================
# AWS CLI v2のインストール
# ============================================================

RUN set -eux; \
    
    # Debianが認識しているCPUアーキテクチャを取得する
    \
    HOST_ARCH="$(dpkg --print-architecture)"; \
    
    # AWS CLI配布ファイルで使われるarchitecture名へ変換する
    \
    case "${HOST_ARCH}" in \
        amd64) AWS_ARCH="x86_64" ;; \
        arm64) AWS_ARCH="aarch64" ;; \
        *) \
            echo "Unsupported architecture for AWS CLI: ${HOST_ARCH}" >&2; \
            exit 1 \
            ;; \
    esac; \
    
    # 固定したAWS CLIバージョンのダウンロードURLを作成する
    \
    AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}-${AWS_CLI_VERSION}.zip"; \
    
    # AWS公式サイトからAWS CLI v2をダウンロードする
    \
    curl \
        --retry 3 \
        --retry-all-errors \
        -fsSLo /tmp/awscliv2.zip \
        "${AWS_CLI_URL}"; \
    \
    # AWS CLIインストーラを/tmpへ展開する
    unzip -q /tmp/awscliv2.zip -d /tmp; \
    
    # AWS CLIを/usr/local/aws-cliへインストールし、
    # /usr/local/bin/awsから実行できるようにする
    \
    /tmp/aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin; \
    
    # AWS CLIインストーラとZIPを削除してImageサイズを削減する
    \
    rm -rf /tmp/aws /tmp/awscliv2.zip


# ============================================================
# インストール結果の検証
# ============================================================

RUN set -eux; \
    \
    # Terraformが想定versionでインストールされたことを確認する
    terraform version | grep "Terraform v${TERRAFORM_VERSION}"; \
    \
    # AWS CLIが想定versionでインストールされたことを確認する
    aws --version 2>&1 | grep "aws-cli/${AWS_CLI_VERSION}"; \
    \
    # jqが正常に実行できることを確認する
    jq --version


# ============================================================
# Terraform実行ユーザーの作成
# 予期せぬroot実行を防ぐため、Terraformはterraformユーザーで実行する
# ============================================================

RUN set -eux; \
    \
    # ホストと同じGIDを持つterraformグループを作成する
    # bind mount先へ作成したファイルのgroupをホストと一致させる
    groupadd \
        --gid "${HOST_GID}" \
        terraform; \
    \
    # ホストと同じUID/GIDを持つterraformユーザーを作成する
    # Terraformをrootユーザーで実行しないための設定
    useradd \
        --uid "${HOST_UID}" \
        --gid "${HOST_GID}" \
        --create-home \
        --shell /bin/bash \
        terraform; \
    \
    # Terraform Providerのキャッシュディレクトリを作成する
    mkdir -p \
        /home/terraform/.terraform.d/plugin-cache; \
    \
    # Terraformコードをmountする作業ディレクトリを作成する
    mkdir -p \
        /workspace/infra; \
    \
    # TerraformユーザーがHOMEとworkspaceへ書き込めるよう所有者を変更する
    chown -R \
        terraform:terraform \
        /home/terraform \
        /workspace


# ============================================================
# Runtime環境変数
# 完成したDocker Imageに残す環境変数
# =============================================================

# TerraformユーザーのHOMEディレクトリを設定する
ENV HOME=/home/terraform \
    \
    # Terraform Providerのダウンロードキャッシュ先を指定する
    # 複数root stackで同じProviderを再利用できる
    TF_PLUGIN_CACHE_DIR=/home/terraform/.terraform.d/plugin-cache \
    \
    # AWS CLIのpagerを無効化する
    # Dockerコンテナ内で「less待ち」になるのを避ける
    AWS_PAGER=""


# ============================================================
# 実行ユーザー
# ============================================================

# ここから先、およびコンテナ起動後はrootではなくterraformユーザーで実行する
USER terraform


# ============================================================
# 作業ディレクトリ
# ============================================================

# コンテナ起動時のデフォルトディレクトリをTerraformコード配置先にする
WORKDIR /workspace/infra


# ============================================================
# デフォルトコマンド
# ============================================================

# docker compose run等でコマンドを指定しなかった場合はbashを起動する
CMD ["bash"]