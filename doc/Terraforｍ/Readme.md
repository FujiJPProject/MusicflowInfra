# Terraform入門 ― 仕組みとコマンドの関係

## はじめに

Terraformは、インフラストラクチャをコードとして定義・管理する **Infrastructure as Code（IaC）** ツールです。

AWS、Azure、Google Cloudなどのクラウドサービスだけでなく、Terraform Providerが対応しているSaaSや各種APIも管理できます。Terraformでは「どのような状態にしたいか」をConfigurationとして記述し、その内容をもとにインフラの作成・変更・削除を行います。

この資料では、個々のコマンドを暗記するのではなく、

> **Terraformがどのような仕組みで動き、その中で各コマンドが何を担当しているのか**

を理解することを目的とします。

---

# 1. Terraformとは何か

Terraformでは、インフラの構成をTerraform Configurationとしてコードに記述します。

例えば、次のようなものをTerraformで管理できます。

* 仮想マシン
* ネットワーク
* ストレージ
* DNS
* データベース
* SaaSサービスの設定

TerraformはConfigurationを読み取り、Providerを介して対象サービスのAPIなどを操作します。

ProviderはTerraformとは別に配布されるプラグインであり、Terraformが利用できるResource TypeやData Sourceを提供します。

概念的には次の関係になります。

```text
Terraform Configuration
        │
        ▼
    Terraform CLI
        │
        ▼
      Provider
        │
        ▼
   サービスのAPI
        │
        ▼
    実際のインフラ
```

つまり、Terraform CLI自体にAWSやAzureなどを操作するすべての機能が組み込まれているわけではありません。

**ProviderがTerraformと対象サービスの橋渡しをします。**

---

# 2. Infrastructure as Code（IaC）の基本

Infrastructure as Codeとは、インフラの構成を手作業だけで管理するのではなく、コードとして定義・管理する考え方です。

Terraformでは、例えば次のような構成をコードで表現できます。

```text
Webサーバーを作成する
        │
        ▼
ロードバランサーを配置する
        │
        ▼
データベースを作成する
        │
        ▼
ネットワークを構成する
```

Configurationをコードとして管理することで、インフラ構成をバージョン管理したり、コードレビューしたりする運用が可能になります。

Terraformは、インフラを構築・変更・バージョン管理するためのIaCツールとして提供されています。

---

# 3. Terraformの全体像

Terraformを理解するために、まず次の5つの要素を押さえます。

```text
┌─────────────────────────┐
│ Configuration (.tf)     │
│ 「どのようにしたいか」  │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│ Terraform CLI           │
│ init / plan / apply ... │
└───────┬─────────┬───────┘
        │         │
        ▼         ▼
   ┌────────┐  ┌────────┐
   │Provider│  │ State  │
   └───┬────┘  └────────┘
       │
       ▼
   外部サービス
       │
       ▼
   実際のインフラ
```

| 要素            | 主な役割                                          |
| ------------- | --------------------------------------------- |
| Configuration | Terraformにどのような構成を管理させるか定義する                  |
| Terraform CLI | Configurationを読み取り、Terraformの処理を実行する          |
| Provider      | 外部サービスやAPIとやり取りする                             |
| State         | Resource Instanceと実際のオブジェクトの対応関係やメタデータなどを保持する |
| 実インフラ         | クラウドなどに実際に存在するリソース                            |

Terraform CLIは、`terraform` コマンドに `init`、`plan`、`apply` などのサブコマンドを指定して利用します。

---

# 4. Terraform Configurationの基本

TerraformのConfigurationは、通常 `.tf` ファイルに記述します。

Terraformは `.tf.json` 形式にも対応しています。

代表的なファイル構成は次のとおりです。

```text
terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
└── versions.tf
```

`main.tf`、`variables.tf`、`outputs.tf` といったファイル名は一般的な構成ですが、Terraformの動作上、それぞれのファイル名に特別な意味があるわけではありません。

同じディレクトリ内にある `.tf` および `.tf.json` ファイルはまとめて1つのModuleとして評価されます。サブディレクトリは自動的には含まれず、別のModuleとして扱われます。

Terraform CLIを実行したWorking Directoryは、通常Root Moduleになります。

例えば、Local Providerを使ってファイルを作成する場合は次のように記述できます。

```hcl
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}

resource "local_file" "hello" {
  filename = "hello.txt"
  content  = "Hello Terraform"
}

output "file_path" {
  value = local_file.hello.filename
}
```

`local_file` は、ローカルファイルを管理するためにLocal Providerが提供しているResource Typeです。

---

# 5. Providerとは

Providerは、Terraformがクラウドサービス、SaaS、その他のAPIなどとやり取りするためのプラグインです。

例えば次のような関係になります。

```text
Terraform
   │
   ├── AWS Provider ───── AWS
   │
   ├── Azure Provider ─── Azure
   │
   ├── Google Provider ── Google Cloud
   │
   └── GitHub Provider ── GitHub
```

各Providerは、Terraformで利用できるResource TypeやData Sourceを提供します。

ProviderはTerraform本体とは別にリリースされ、それぞれ独自のバージョンを持っています。

利用するProviderは `required_providers` で宣言します。

```hcl
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}
```

実務では、意図しないProviderのバージョンアップを避けるため、利用可能なProvider VersionをConfigurationで制約することが推奨されています。

必要なProviderは、Terraform CLIを利用する場合、後述する `terraform init` でインストールされます。

---

# 6. Resourceとは

Resourceは、**Terraformが作成・変更・削除などの管理を行う対象**を表します。

基本形は次のとおりです。

```hcl
resource "RESOURCE_TYPE" "NAME" {
  # 設定
}
```

例えば、

```hcl
resource "local_file" "hello" {
  filename = "hello.txt"
  content  = "Hello Terraform"
}
```

では、

```text
local_file
```

がResource Type、

```text
hello
```

がそのResourceにつけたローカル名です。

このResourceは、

```text
local_file.hello
```

という形式で参照できます。

Resource Typeとローカル名の組み合わせは、State内でもResourceを識別するためのAddressの基本になります。

---

# 7. Data Sourceとは

Data Sourceは、Providerなどを通して**外部に存在する情報を取得するための仕組み**です。

Resourceとの基本的な違いは次のとおりです。

```text
Resource
  → Terraformが管理する対象を定義する

Data Source
  → 既存の情報を取得して参照する
```

Data SourceはProviderからデータを取得しますが、その対象を作成・変更するものではありません。

基本形は次のとおりです。

```hcl
data "TYPE" "NAME" {
  # 検索条件など
}
```

取得した値は、

```text
data.TYPE.NAME.ATTRIBUTE
```

のような形式で参照できます。

---

# 8. Variables・Local Values・Outputs

Terraformでは値を直接Configurationに書くだけでなく、Input Variables、Local Values、Output Valuesを利用できます。

これらを利用することで、Moduleを柔軟で再利用しやすい構成にできます。

## Input Variable

外部からModuleへ値を渡すために使用します。

```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

参照するときは、

```hcl
var.environment
```

と記述します。

---

## Local Value

Module内部で式や値に名前をつけ、再利用するために使用します。

```hcl
locals {
  application_name = "sample-app"
}
```

参照するときは、

```hcl
local.application_name
```

と記述します。

---

## Output Value

Moduleの外部へ値を公開するために使用します。

```hcl
output "file_path" {
  value = local_file.hello.filename
}
```

Output ValueはCLIに値を表示したり、他のModuleやTerraform Configurationから値を利用したりするために使用できます。

---

# 9. Moduleとは

Terraform Moduleは、同じディレクトリに配置されたTerraform Configurationのまとまりです。

Terraform CLIを実行する対象となるModuleを **Root Module** と呼び、`module` blockから呼び出されるModuleを **Child Module** と呼びます。

例えば、Webサーバーに必要な構成をまとめて、

```text
modules/
└── web-server/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

のようなModuleを作成できます。

呼び出す側では次のように記述します。

```hcl
module "web_server" {
  source = "./modules/web-server"
}
```

Moduleを利用することで、複数のResource定義を再利用可能な単位としてまとめられます。

---

# 10. Resource間の参照と依存関係

Terraformは、Resource間の参照を解析して依存関係を推論します。

概念例：

```hcl
resource "example_network" "main" {
}

resource "example_server" "web" {
  network_id = example_network.main.id
}
```

`example_server.web` が

```text
example_network.main.id
```

を参照しているため、Terraformは概念的に次の依存関係を認識できます。

```text
Network
   │
   ▼
Server
```

通常は、このような参照からTerraformが依存関係を自動的に判断します。

参照だけではTerraformが認識できない依存関係がある場合には、`depends_on` を利用できます。

ただし、HashiCorpは可能な限り通常の式による参照で依存関係を表し、`depends_on` は隠れた依存関係を明示する必要がある場合に使用することを推奨しています。

---

# 11. Terraform Stateとは

StateはTerraformの非常に重要な仕組みです。

TerraformはStateを使って、

```text
Configuration上のResource Instance
```

と

```text
実際のシステム上に存在するオブジェクト
```

を対応付けます。

Stateにはこの対応関係だけでなく、Terraformが管理に利用するメタデータなども保存されます。

例えば、

```text
Configuration

aws_instance.web
        │
        │ Stateで対応付け
        ▼
AWS上の実際のEC2インスタンス
```

という関係になります。

StateはTerraformが対象のインフラを継続的に管理するために必要なデータです。

---

# 12. Configuration・State・実リソースの関係

`terraform plan` の動きを理解するには、Configuration・State・実リソースの関係が重要です。

通常のPlan作成では、Terraformは次のような処理を行います。

1. 既存のリモートオブジェクトの現在状態を読み取る
2. Stateを現在の状態に合わせる
3. 現在のConfigurationと以前のStateを比較する
4. Configurationに一致させるために必要な変更を提案する

これはHashiCorp公式ドキュメントで説明されている `terraform plan` の基本動作です。

概念的には次のように考えられます。

```text
        Configuration
     「どうしたいか」
              │
              ▼
            plan
          /       \
         ▼         ▼
      State      実リソース
```

例えばConfigurationでは、

```text
サーバー：2台
```

となっており、現在は1台しか存在していない場合、Terraformは必要に応じて、

```text
+ サーバーを1台作成
```

という変更をPlanとして提案します。

したがって、Terraformを

> `.tf` ファイルとStateだけを単純に比較するツール

と理解するのは正確ではありません。

**Configuration、State、実際のリモートオブジェクトをもとに、必要な変更を判断する**

と理解するのが適切です。

---

# 13. Backendとは

Backendは、TerraformがStateデータをどこに保存するかを定義する仕組みです。

Backendを指定しなければ、Terraformはデフォルトで `local` Backendを使用します。

```text
Terraform
   │
   ▼
terraform.tfstate
```

`local` BackendではStateがローカルディスクに保存されます。

一方、チームでTerraformを利用する場合には、Stateをリモートに保存するBackendを利用できます。

```text
Developer A ─┐
             │
Developer B ─┼── リモートのState保存先
             │
CI/CD ───────┘
```

HashiCorpは、StateをHCP TerraformまたはリモートBackendへ保存することを推奨しています。

Backend Configurationを変更した場合には、再度 `terraform init` を実行してBackendを初期化する必要があります。

> **補足:** HCP TerraformまたはTerraform EnterpriseのWorkspaceと `cloud` blockを使用する場合は、通常の `backend` blockとは異なる仕組みでStateが管理されます。

---

# 14. リモートStateとState Locking

複数人が同じStateを同時に変更すると、競合やState破損につながる可能性があります。

Terraformでは、使用しているBackendがState Lockingに対応している場合、Stateを書き換える可能性がある処理で自動的にLockを取得します。

```text
User A
  │
  ├── StateをLock
  │
  ▼
terraform apply

User B
  │
  └── Lockを取得できるまで
      同じStateへの書き込みを実行できない
```

重要なのは、

> **すべてのBackendがState Lockingをサポートしているわけではない**

という点です。

チーム利用では、

* Stateを安全な場所に保存する
* 適切なアクセス制御を行う
* 利用するBackendのState Locking対応状況を確認する

ことが重要です。

---

# 15. Terraformの基本ワークフロー

Terraformの操作は、大きく

```text
初期化
```

と

```text
日常的な変更作業
```

に分けて考えると理解しやすくなります。

## 最初の準備

新しいConfigurationを作成した場合や、Version Controlから取得した直後などに、

```bash
terraform init
```

を実行します。

また、Provider Requirements、Module Source、Backend Configurationなどを変更した場合にも再度 `terraform init` が必要になることがあります。

---

## 日常的な変更

```text
Configurationを変更
        │
        ▼
terraform fmt
        │
        ▼
terraform validate
   （必要に応じて）
        │
        ▼
terraform plan
        │
        ▼
Planを確認
        │
        ▼
terraform apply
```

ここで重要なのは、

> **毎回 `terraform init` を実行する必要はない**

ということです。

また、`terraform validate` も必須工程ではありません。

`terraform plan` と `terraform apply` はConfigurationのValidationを内部的に実行します。`validate` は、エディタ、pre-commit、CIなどでConfiguration単体を検証したい場合に特に有用です。

---

# 16. terraform init ― Working Directoryを初期化する

```bash
terraform init
```

は、Terraform Configurationを含むWorking Directoryを初期化するコマンドです。

Terraform CLIを利用する場合、新しいConfigurationを作成した後やVersion Controlから取得した後に、最初に実行する代表的なコマンドです。

`init` では主に、

* 設定されたBackendへのアクセス・初期化
* 必要なProvider Pluginのダウンロードとインストール
* Child Moduleのダウンロード

などが行われます。

```text
terraform init
      │
      ├── Backendを初期化
      │
      ├── Providerを取得
      │
      └── Moduleを取得
```

したがって、

> `init` = Terraformを実行するためにWorking Directoryを準備する

と理解するとよいでしょう。

---

# 17. `.terraform` と `.terraform.lock.hcl`

`terraform init` を実行すると、Working DirectoryにはTerraformが使用するファイルやディレクトリが作成されます。

代表的なものは次の2つです。

```text
project/
├── main.tf
├── .terraform/
└── .terraform.lock.hcl
```

## `.terraform/`

`.terraform` はTerraformが自動管理するディレクトリです。

主に、

* キャッシュされたProvider Plugin
* ダウンロードしたModule
* 現在のWorkspaceに関する情報
* 最後に認識したBackend Configuration

などを管理します。

Backendに関する認証情報が含まれる可能性もあるため、`.terraform/` はVersion Controlへコミットすべきではありません。

---

## `.terraform.lock.hcl`

`.terraform.lock.hcl` はDependency Lock Fileです。

現在、このLock Fileが記録する外部依存関係は **Provider** です。Remote Moduleの選択バージョンは `.terraform.lock.hcl` には記録されません。

Terraformは `terraform init` の実行時に、このファイルを必要に応じて作成・更新します。

HashiCorpは `.terraform.lock.hcl` をVersion Controlに含めることを推奨しています。

```text
Version Controlに含める

✓ main.tf
✓ variables.tf
✓ outputs.tf
✓ .terraform.lock.hcl

通常は含めない

✗ .terraform/
✗ terraform.tfstate
```

---

# 18. terraform fmt ― Configurationを整形する

```bash
terraform fmt
```

はTerraform Configurationを標準的な形式へ整形するコマンドです。

例えば、

* インデント
* 空白
* Terraform標準の書式

などを整えます。

Configurationを編集した後は、

```bash
terraform fmt
```

を実行して書式を統一する習慣をつけるとよいでしょう。

CIなどで書式が正しいか確認する場合には、

```bash
terraform fmt -check
```

も利用できます。

---

# 19. terraform validate ― Configurationを検証する

```bash
terraform validate
```

は、Terraform Configurationが構文的に正しく、内部的に整合しているかを検証するコマンドです。

例えば、

* 構文が正しいか
* ResourceやModuleのAttribute名などが妥当か
* Value Typeが整合しているか

といった内容を検証します。

重要なのは、

> **クラウドなどのRemote Serviceが正しく動作するかを検証するコマンドではない**

という点です。

`validate` はRemote StateやProvider APIなどのRemote Serviceを検証しません。

したがって、

```text
terraform validate が成功した
```

からといって、

```text
terraform apply も必ず成功する
```

という意味ではありません。

また、`terraform plan` にはValidationが含まれているため、`validate` を毎回手作業で実行することはTerraformの必須ワークフローではありません。

---

# 20. terraform plan ― 変更内容を計算・確認する

```bash
terraform plan
```

はExecution Planを作成し、Terraformがインフラに対してどのような変更を行おうとしているか確認するためのコマンドです。

通常、TerraformはPlan作成時に、

1. 既存のRemote Objectの現在状態を読み取る
2. 現在のConfigurationと以前のStateを比較する
3. Configurationに一致させるための変更操作を提案する

という処理を行います。

例えば、

```text
+ create
~ update
- destroy
```

といった変更予定が表示されます。

概念的には、

```text
Configuration
      │
      ├──── State
      │
      └──── 実リソース
             │
             ▼
       Execution Plan
```

と考えられます。

重要なのは、

> **`terraform plan` を実行しただけでは、通常、提案されたインフラ変更は実行されない**

という点です。

つまり、

```text
plan = 何が変わるのかを確認する
```

と覚えるとよいでしょう。

---

# 21. terraform apply ― Planを実行する

```bash
terraform apply
```

は、Terraform Planで提案された操作を実行するコマンドです。

概念的には、

```text
Execution Plan
      │
      ▼
terraform apply
      │
      ▼
Provider
      │
      ▼
外部サービスのAPI
      │
      ▼
実際のインフラ
```

という流れになります。

Providerを通じて対象サービスに対する操作が行われ、Terraformは管理対象の情報をStateにも反映します。

---

# 22. plan と apply の関係

入門時に特に誤解しやすいポイントです。

よく見る操作は、

```bash
terraform plan
terraform apply
```

ですが、`terraform plan` を必ず独立したコマンドとして実行しなければならないわけではありません。

保存済みPlanを指定せずに、

```bash
terraform apply
```

を実行すると、Terraformは新しいExecution Planを自動的に作成し、対話的な利用では承認を求めた後に変更を実行します。

つまり、

```text
terraform apply
      │
      ├── Plan作成
      │
      ├── Plan確認・承認
      │
      └── Apply
```

という動作になります。

一方、Planをファイルへ保存することもできます。

```bash
terraform plan -out=tfplan
```

作成したPlanは、

```bash
terraform apply tfplan
```

で実行できます。

```text
terraform plan -out=tfplan
          │
          ▼
      保存済みPlan
          │
          ▼
terraform apply tfplan
```

HashiCorpは、この2段階の方法を主にAutomationで利用するワークフローとして説明しています。

---

# 23. terraform destroy ― 管理対象を削除する

```bash
terraform destroy
```

は、そのTerraform Configurationで管理されているオブジェクトを削除するためのコマンドです。

例えば検証用環境を作成した後、

```bash
terraform destroy
```

でTerraform管理下のリソースを削除できます。

現在のTerraformでは、

```bash
terraform destroy
```

は、

```bash
terraform apply -destroy
```

のConvenience Alias（便利な別名）として提供されています。

実際に削除せず、削除予定だけを確認したい場合は、

```bash
terraform plan -destroy
```

を使用できます。

本番環境などでのDestroy操作は大きな影響を与える可能性があるため、Planの内容を十分に確認することが重要です。

---

# 24. Terraform RegistryとProvider・Module

Terraform Registryでは、公開されているProviderやModuleを検索できます。

Terraform Registryは、公開Providerを探すための主要なディレクトリとしてTerraformから利用されています。

Providerは例えば次のように指定します。

```hcl
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}
```

公開Moduleなども `module` blockの `source` から指定できます。

Terraformの仕組みを理解する上では、

```text
Terraform本体に
すべてのクラウド機能が入っている
```

のではなく、

```text
Terraform CLI
      +
   Provider
      +
    Module
```

というエコシステムになっていることを理解することが重要です。

---

# 25. State管理で注意すべきこと

Stateには、Terraformが管理しているインフラの詳細な情報が含まれます。

Resourceの属性によっては、パスワードやTokenなどの機密情報がStateに含まれる可能性もあります。

例えば、

```hcl
sensitive = true
```

を指定したInput VariableやOutput ValueはCLIなどで値を隠せますが、`sensitive` を指定しただけでは、その値がStateやPlanから削除されるわけではありません。

そのため、Stateは機密情報として扱う必要があります。

HashiCorpは、StateをVersion Controlへ保存せず、State Lockingや安全なアクセス制御を利用できる保存方法を推奨しています。

基本的には、

```text
✓ Stateは安全なBackendなどへ保存する
✓ アクセス権を適切に制御する
✓ 利用可能ならState Lockingを使用する
✓ Stateを機密情報として扱う

✗ terraform.tfstateをGitにコミットする
✗ Stateを無制限に共有する
```

と考えます。

> **補足:** 現行Terraformには、値をStateやPlanに保存しないための `ephemeral` の仕組みもあります。`sensitive` は「表示を隠す」ための仕組みであり、「保存しない」こととは異なります。

---

# 26. Terraform利用時によくある失敗

## 1. 必要な `terraform init` を実行していない

新しいWorking Directoryでは、Terraformの通常操作を行う前に初期化が必要です。

また、

* Provider Requirements
* Module SourceやVersion Constraint
* Backend Configuration

などを変更した場合にも再初期化が必要になることがあります。

```bash
terraform init
```

を実行します。

---

## 2. Planを十分確認せずApplyする

TerraformはResourceの作成だけでなく、変更・削除も行います。

例えばPlanに、

```text
- destroy
```

などの意図しない変更が表示されていないかを確認することが重要です。

---

## 3. Stateを安易に削除・編集する

Stateを失うと、

```text
実際のResourceは存在している
        │
        ▼
Terraformとの対応関係が失われる
```

という状態になる可能性があります。

TerraformはStateによってResource Instanceと実際のRemote Objectを対応付けています。

また、HashiCorpはStateファイルを直接編集せず、必要な変更には `terraform state` コマンドなどを利用するよう説明しています。

---

## 4. `.terraform.lock.hcl` を毎回削除する

Dependency Lock Fileは、Providerの選択バージョンを安定させる役割があります。

通常はVersion Controlに含めます。

---

## 5. `depends_on` を必要以上に使用する

Terraformは通常、Resource間の参照から依存関係を推論できます。

そのため、`depends_on` はTerraformが通常の参照だけでは認識できない依存関係を表す場合に使用します。

---

# 27. 実務でのTerraform開発・運用フロー

日常的なConfiguration変更は、概念的には次のような流れになります。

```text
① Configuration変更
        │
        ▼
② terraform fmt
        │
        ▼
③ terraform validate
   （必要に応じて）
        │
        ▼
④ terraform plan
        │
        ▼
⑤ Planをレビュー
        │
        ▼
⑥ terraform apply
```

`terraform validate` は独立した必須工程ではなく、CIやpre-commitなどでConfigurationを事前確認する場合に有用です。`plan` と `apply` にはValidationが含まれています。

チーム開発では例えば、

```text
Configuration変更
        │
        ▼
       Git
        │
        ▼
Pull Request
        │
        ├── terraform fmt -check
        │
        ├── terraform validate
        │
        └── terraform plan
                 │
                 ▼
              Review
                 │
                 ▼
               Merge
                 │
                 ▼
          terraform apply
```

のようにCI/CDと組み合わせることがあります。

重要なのは、

> **実際に変更を適用する前に、Planで変更内容を確認できる**

というTerraformの特性を活用することです。

---

# 28. 主要Terraformコマンド早見表

| コマンド                 | 主な役割                          |
| -------------------- | ----------------------------- |
| `terraform init`     | Working Directoryを初期化する       |
| `terraform fmt`      | Configurationを標準形式へ整形する       |
| `terraform validate` | Configurationが構文的・内部的に妥当か検証する |
| `terraform plan`     | Execution Planを作成し、変更予定を確認する  |
| `terraform apply`    | Terraform Planの操作を実行する        |
| `terraform destroy`  | 管理対象のオブジェクトを削除する              |
| `terraform output`   | Root ModuleのOutput Valueを表示する |
| `terraform show`     | Stateや保存済みPlanを人が読める形式で表示する   |
| `terraform state`    | Stateを操作するためのサブコマンド群          |

Terraform CLIは、

```text
terraform <subcommand>
```

という形式で利用します。

入門段階では、まず次のコマンドを理解するとよいでしょう。

```text
init      = 初期化・準備
fmt       = 整形
validate  = Configurationの検証
plan      = 変更計画
apply     = 変更の実行
destroy   = 削除
```

単に順番を暗記するのではなく、**それぞれがTerraformのどの処理を担当しているか**を理解することが重要です。

---

# 29. まとめ ― Terraformの仕組みとコマンドの関係

Terraformの全体像を整理すると、次のようになります。

```text
                 Configuration
              「どうしたいか」
                     │
                     ▼
               Terraform CLI
                     │
          ┌──────────┴──────────┐
          │                     │
          ▼                     ▼
        State                Provider
          ▲                     │
          │                     ▼
          │              外部サービスAPI
          │                     │
          │                     ▼
          └───────────── 実インフラ


初回・構成変更時
    terraform init
          │
          ├── Backendを初期化
          ├── Providerを取得
          └── Moduleを取得


日常的な変更
Configuration
      │
      ▼
terraform plan
      │
      ▼
Execution Plan
      │
      ▼
terraform apply
      │
      ▼
実インフラ
```

Terraformを理解する上で、特に重要なのは次の4点です。

## 1. Configuration

```text
どのような構成にしたいか
```

を定義します。

---

## 2. Provider

```text
Terraform
    │
    ▼
外部サービス
```

をつなぐ役割を持ちます。

---

## 3. State

```text
Configuration上のResource Instance
              ↕
       実際のRemote Object
```

の対応関係や、Terraformが管理に必要とする情報を保持します。

---

## 4. CLIコマンド

```text
terraform init
```

でWorking Directoryを初期化し、

```text
terraform plan
```

で変更計画を作成・確認し、

```text
terraform apply
```

でPlanの操作を実行します。

