# コンテナ環境

## ベースOS

**debian:bookworm-slim**

 - debian採用の理由
   - AWS CLI v2やTerraformのLinuxバイナリを問題なく利用しやすい
   - Ubuntuほど初期パッケージが多くない
   - Alpine Linuxより一般的なLinuxソフトウェアとの互換性を考えやすい
 - bookwormでバージョンを固定し勝手に変わることを防ぐ
 - slimで軽量化。必要なツールは自分でapt installする

## 基本インストールツール

|ツール|目的|
|:--|:--|
|bash|LinuxのShell|
|ca-certificates|HTTPS通信時に、接続先Webサイトの証明書が信頼できるかを判断するためのCA証明書群|
|curl|HTTP/HTTPSでファイルを取得するツール|
|groff|AWS CLIのヘルプ表示などで使われる文書整形ツール|
|jq|JSONを加工・抽出するCLIツール|
|unzip|Zip形式ファイルの操作|

## ファイル所有権対策

ホストと同一のUIDを持つユーザーをコンテナ内に作成し、所有権問題を回避する

```
ホスト
ユーザー(XXX)
UID 1000
    │
    │ 同じ数字
    ▼
Docker
ユーザー(terraform)
UID 1000
```

## キャッシュ戦略

`terraform init`を実施すると同じAWS Providerを毎回取得する羽目になる

そのため

**最初**
```
03-network
    ↓
AWS Provider 6.58.0をdownload
    ↓
plugin-cacheへ保存
```

**2回目以降**
```
03-network
    ↓
plugin-cache確認
    ↓
AWS Provider 6.58.0がある
    ↓
再利用
```

### .terraformとの違い

```
.terraform/
→ root stackごと
→ Terraform内部作業用

plugin-cache/
→ root stack間で共有
→ Provider再ダウンロード防止
```