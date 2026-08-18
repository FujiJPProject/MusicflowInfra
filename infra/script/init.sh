#!/usr/bin/env bash

set -euo pipefail

# このスクリプト自身が存在するinfra/scriptsを基準に
# infraディレクトリの絶対パスを取得する。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

BACKEND_CONFIG="${INFRA_DIR}/backend/shared.s3.tfbackend"

if [[ ! -f "${BACKEND_CONFIG}" ]]; then
  echo "Backend config not found: ${BACKEND_CONFIG}" >&2
  exit 1
fi

# 呼び出したTerraform root stackを対象として
# 共通backend設定を読み込む。
terraform init \
  -backend-config="${BACKEND_CONFIG}" \
  "$@"