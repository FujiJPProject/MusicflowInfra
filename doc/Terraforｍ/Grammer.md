# Terraform HCL入門

## 1. この資料について

### 1.1 目的

この資料では、Terraformを初めて利用するエンジニアを対象に、Terraformの設定ファイルで使用するHCLとTerraform Languageの基本を説明します。

最終的には、次のようなTerraformコードを自分で読めることを目標とします。

```hcl
resource "aws_s3_bucket" "example" {
  bucket = local.bucket_name

  tags = {
    Environment = var.environment
  }
}
```

さらに、AWS Providerを利用してS3 Bucketを作成し、

```text
terraform init
↓
terraform fmt
↓
terraform validate
↓
terraform plan
↓
terraform apply
↓
terraform output
↓
terraform destroy
```

まで実際に確認します。

TerraformはInfrastructure as Code（IaC）ツールであり、Terraform Languageを使ってInfrastructureの望ましい状態を記述します。Terraform Languageでは、ブロック、引数、式などを組み合わせてConfigurationを構成します。

---

# 2. HCLとTerraform Language

## 2.1 HCLとは

HCLは **HashiCorp Configuration Language** の略です。

Terraform Languageの低レベルな構文はHCLを基盤としています。

ただし、

```text
HCL = Terraform専用言語
```

ではありません。

HCLはTerraform以外のHashiCorp製品などでも利用される、より一般的なConfiguration Languageの構文です。

Terraformでは、そのHCLを基盤としてTerraform固有のブロックや意味を定義しています。

概念的には次のように考えます。

```text
HCL
├─ ブロック
├─ 引数
├─ 式を記述するための構文
└─ コメントなど

Terraform Language
├─ terraform
├─ provider
├─ resource
├─ data
├─ variable
├─ locals
├─ output
├─ module
└─ Terraform固有の意味・動作
```

---

## 2.2 Terraform Configurationとは

Terraform LanguageでInfrastructureの構成を記述したものをTerraform Configurationと呼びます。

通常は、

```text
main.tf
variables.tf
outputs.tf
providers.tf
versions.tf
```

などの`.tf`ファイルへ記述します。

ただし、**`main.tf`や`variables.tf`というファイル名自体にTerraformの特別な意味があるわけではありません。**

Terraformでは、同一ディレクトリ直下にある`.tf`および`.tf.json`ファイルをまとめて1つのModuleとして扱います。

Nested Directoryは自動的には読み込まれず、別のModuleとして扱われます。

そのため、

```text
main.tf
variables.tf
outputs.tf
```

に分割しても、

```text
terraform.tf
```

という1ファイルにまとめても、Terraform Language上は同じModuleを構成できます。

ファイル分割は主に可読性や保守性を高めるために行います。

---

# 3. Terraform Languageの基本構造

Terraform公式のConfiguration Syntaxでは、Terraform Languageの構文は主に、

```text
引数（Argument）
ブロック（Block）
```

を中心に構成されています。

そして、引数の右辺などに、

```text
式（Expression）
```

を記述します。

学習上は、

```text
Block
Argument
Expression
```

の3つをセットで理解すると分かりやすくなります。

---

# 4. ブロック（Block）

ブロックは、設定をひとまとまりにする構造です。

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
}
```

このコードを分解すると、

```text
resource
└─ Block Type

"aws_s3_bucket"
└─ Label

"example"
└─ Label

{
  ...
}
└─ Block Body
```

となります。

一般形は、

```hcl
block_type "label1" "label2" {
  # Block Body
}
```

です。

必要なLabelの数やBlock Bodyの内容はBlock Typeによって異なります。例えば`resource`ブロックでは2つのLabelを使用します。

---

# 5. 引数（Argument）

引数は、

```text
名前 = 式
```

という形式で値を設定します。

例：

```hcl
bucket = "example-bucket"
```

では、

```text
bucket
```

が引数名、

```text
"example-bucket"
```

が式です。

一般形は、

```hcl
argument_name = expression
```

です。

---

# 6. 式（Expression）

式は、値を表したり計算したりする記述です。

最も単純なものはLiteral Valueです。

```hcl
name    = "example"
count   = 3
enabled = true
```

ほかにも、

```hcl
var.environment
```

のような参照、

```hcl
var.environment == "prod" ? 3 : 1
```

のようなConditional Expression、

```hcl
upper(var.environment)
```

のようなFunction Callも式です。

---

# 7. ブロックと引数の違い

例えば、

```hcl
resource "example_resource" "example" {
  name = "sample"

  lifecycle {
    prevent_destroy = true
  }
}
```

では、

```text
resource
└─ Block

name = "sample"
└─ Argument

lifecycle
└─ Nested Block

prevent_destroy = true
└─ Argument
```

という構造です。

基本的には、

```text
name = expression
→ 引数

type ... {
}
→ ブロック
```

として区別します。

---

# 8. コメント

Terraform Languageでは3種類のコメントを使用できます。

```hcl
# 1行コメント

// 1行コメント

/*
複数行
コメント
*/
```

Terraform公式では、通常の1行コメントには`#`を使用することが推奨されています。

---

# 9. 値とデータ型

Terraformには主に次の型があります。

```text
Primitive Type
├─ string
├─ number
└─ bool

Collection Type
├─ list
├─ set
└─ map

Structural Type
├─ tuple
└─ object

特殊な値
└─ null
```

`null`はStringやNumberのような型ではなく、値が存在しないことを表す特殊な値です。

---

# 10. String

文字列です。

```hcl
name = "terraform"
```

---

# 11. Number

数値です。

```hcl
port = 8080
```

Terraformでは整数型と浮動小数点型を別々に定義せず、`number`として扱います。

---

# 12. Bool

真偽値です。

```hcl
enabled = true
```

または、

```hcl
enabled = false
```

です。

---

# 13. List

同一型の値を順序付きで扱うCollection Typeです。

```hcl
variable "availability_zones" {
  type = list(string)

  default = [
    "ap-northeast-1a",
    "ap-northeast-1c"
  ]
}
```

---

# 14. Tuple

Tupleは要素ごとに異なる型を持てるStructural Typeです。

```hcl
[
  "terraform",
  10,
  true
]
```

`[...]`で生成した値はTupleとして扱われ、必要に応じて互換性のあるListなどへTerraformが変換する場合があります。

---

# 15. Map

MapはKeyとValueの組み合わせで値を管理します。

```hcl
variable "instance_types" {
  type = map(string)

  default = {
    dev  = "t3.micro"
    prod = "t3.medium"
  }
}
```

参照：

```hcl
var.instance_types["dev"]
```

---

# 16. Object

Objectは属性ごとに型を定義できるStructural Typeです。

```hcl
variable "application" {
  type = object({
    name    = string
    enabled = bool
    port    = number
  })
}
```

値：

```hcl
application = {
  name    = "music-app"
  enabled = true
  port    = 8080
}
```

---

# 17. Set

Setは重複要素を持たず、順序を保証しないCollectionです。

```hcl
locals {
  environments = toset([
    "dev",
    "staging",
    "prod"
  ])
}
```

特に`for_each`と組み合わせて使用することがあります。

`toset()`でListからSetへ変換すると、重複値と元の順序は失われます。

---

# 18. null

`null`は値が存在しないことを表します。

```hcl
variable "description" {
  type    = string
  default = null
}
```

例えばOptionalな設定を省略する用途などに利用します。

---

# 19. Type Constraint

入力変数では、受け付ける値の型を制限できます。

```hcl
variable "name" {
  type = string
}
```

代表的なType Constraintは次のとおりです。

```hcl
string
number
bool

list(string)
set(string)
map(string)

tuple([
  string,
  number
])

object({
  name    = string
  enabled = bool
})
```

---

## 19.1 optional

Object属性をOptionalにできます。

```hcl
variable "application" {
  type = object({
    name = string
    port = optional(number, 8080)
  })
}
```

`port`を省略した場合は`8080`がDefault Valueとして使用されます。

---

## 19.2 any

Type Constraintには`any`もあります。

```hcl
variable "value" {
  type = any
}
```

ただし、明確な型が分かっている場合には具体的な型を指定するほうが、入力エラーを早い段階で検出しやすくなります。

---

# 20. Terraformでよく使用するブロック

Terraform Configurationでは特に、

```text
terraform
provider
resource
data
variable
locals
output
module
```

をよく使用します。

---

# 21. terraformブロック

Terraform自身の動作条件などを設定します。

```hcl
terraform {
  required_version = ">= 1.15.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

`terraform`ブロックでは、

```text
Terraform CLIのVersion
Required Providers
Backend
HCP Terraformとの接続
```

などを設定できます。

なお、`terraform`ブロックの設定には基本的に定数値を使用し、ResourceやInput Variableなどを参照することはできません。

`~> 6.0`は、6.x系の範囲でProvider Versionを許可するVersion Constraintです。

---

# 22. providerブロック

ProviderはTerraformと外部システムのAPIを接続するPluginです。

AWSの場合、

```hcl
provider "aws" {
  region = "ap-northeast-1"
}
```

とします。

概念的には、

```text
Terraform Core
     ↓
AWS Provider
     ↓
AWS API
     ↓
S3 / EC2 / Lambda / RDS ...
```

という関係です。

ProviderはTerraform本体とは別にVersion管理されています。

---

# 23. resourceブロック

ResourceはTerraformが管理するInfrastructure Objectを定義します。

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
}
```

この場合、

```text
aws_s3_bucket
→ Resource Type

example
→ Resource Name
```

です。

参照するときは、

```hcl
aws_s3_bucket.example
```

のように記述します。

各Resourceで利用可能な引数や属性はTerraform Coreではなく、Provider側が定義します。

---

# 24. dataブロック

Data Sourceは、Providerなどを通してデータを読み取るための仕組みです。

例えば、現在使用しているAWS CredentialのAccount IDを取得します。

```hcl
data "aws_caller_identity" "current" {}
```

参照：

```hcl
data.aws_caller_identity.current.account_id
```

`data`ブロックで利用できる設定や返される属性もProvider側によって定義されます。

---

# 25. variableブロック

Input VariableはModuleへ外部から値を渡すための仕組みです。

```hcl
variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}
```

参照：

```hcl
var.environment
```

Root ModuleではCLI、環境変数、Variable Definition Fileなどから値を設定できます。

Child ModuleではParent Moduleの`module`ブロックから値を渡します。

---

# 26. Variable Validation

Input VariableにValidationを設定できます。

```hcl
variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )

    error_message = "environment must be dev, staging, or prod."
  }
}
```

`condition`が`false`の場合、Validation Errorになります。

---

# 27. Variableへ値を渡す方法

例えば、

```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

に対して、複数の方法で値を設定できます。

## terraform.tfvars

```hcl
environment = "staging"
```

## CLI

```bash
terraform plan -var="environment=prod"
```

## Environment Variable

```bash
export TF_VAR_environment=prod
```

Terraform公式の優先順位は、高い順に次のようになります。

```text
1. -var / -var-file、およびHCP Terraformから設定される値
2. *.auto.tfvars / *.auto.tfvars.json
3. terraform.tfvars.json
4. terraform.tfvars
5. TF_VAR_*などのVariable用環境変数
6. variableブロックのdefault
```

同じVariableへ複数の値が設定された場合、この優先順位に基づいて値が決定されます。

---

# 28. Local Values

Local ValuesはModule内部で式や値を再利用するための仕組みです。

```hcl
locals {
  application_name = "${var.project_name}-${var.environment}"
}
```

参照：

```hcl
local.application_name
```

概念的には、

```text
variable
→ Moduleの入力

local
→ Module内部で利用する計算済み・整理済みの値
```

と考えると分かりやすくなります。

---

# 29. Output Values

Output ValueはModuleから値を公開する仕組みです。

```hcl
output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}
```

Root ModuleのOutputは、

```bash
terraform output
```

で確認できます。

Child ModuleのOutputはParent Moduleから、

```hcl
module.storage.bucket_name
```

のように参照します。

`terraform output`で直接表示できるのはRoot ModuleのOutputです。Child ModuleのOutputをCLIへ公開する場合はRoot ModuleのOutputへ中継します。

---

# 30. 値の参照

代表的な参照形式は次のとおりです。

```text
Input Variable
var.<NAME>

Local Value
local.<NAME>

Resource
<TYPE>.<NAME>.<ATTRIBUTE>

Data Source
data.<TYPE>.<NAME>.<ATTRIBUTE>

Child Module Output
module.<NAME>.<OUTPUT>
```

TerraformではResource、Input Variable、Local Value、Child Module Output、Data SourceなどをNamed Valueとして式から参照できます。

---

# 31. Resource間の依存関係

例えば、

```hcl
resource "aws_s3_bucket" "example" {
  bucket = local.bucket_name
}

output "bucket_arn" {
  value = aws_s3_bucket.example.arn
}
```

では、

```hcl
aws_s3_bucket.example.arn
```

という参照からTerraformが依存関係を判断できます。

Terraformはこうした参照を利用してDependency Graphを構築し、必要な順序で処理を実行します。

---

## 31.1 depends_on

通常の参照では表現できないHidden Dependencyがある場合、

```hcl
depends_on = [
  aws_s3_bucket.example
]
```

を使用できます。

`depends_on`は、指定されたDependency Objectに関するActionやReadが完了してから対象Objectを処理するようTerraformへ明示します。

通常は値の参照によって依存関係を表現し、それでは表現できない場合に`depends_on`を使用します。

---

# 32. Operator

TerraformではOperatorを利用できます。

## Arithmetic Operator

```hcl
1 + 2
10 - 3
5 * 2
10 / 2
10 % 3
```

## Comparison Operator

```hcl
1 < 2
1 <= 2
2 > 1
2 >= 1
```

## Equality Operator

```hcl
a == b
a != b
```

## Logical Operator

```hcl
a && b
a || b
!a
```

---

# 33. Conditional Expression

条件によって値を変更できます。

```hcl
instance_count = var.environment == "prod" ? 3 : 1
```

構造：

```text
condition
  ?
trueの場合の値
  :
falseの場合の値
```

---

# 34. for Expression

Collectionを別の値へ変換できます。

```hcl
locals {
  environments = [
    "dev",
    "staging",
    "prod"
  ]

  upper_environments = [
    for environment in local.environments :
    upper(environment)
  ]
}
```

結果：

```text
[
  "DEV",
  "STAGING",
  "PROD"
]
```

Filteringもできます。

```hcl
[
  for environment in local.environments :
  environment
  if environment != "dev"
]
```

`for` ExpressionはComplex Typeの値を別のComplex Typeへ変換するために利用します。

---

# 35. String Template

## 35.1 Interpolation

String内へExpressionを埋め込めます。

```hcl
name = "${var.project_name}-${var.environment}"
```

`${ ... }`がInterpolation Sequenceです。

単純に値をそのまま設定するだけなら、

```hcl
bucket = var.bucket_name
```

のように`${}`で囲む必要はありません。

---

## 35.2 Template Directive

String Templateでは条件分岐なども利用できます。

```hcl
message = <<-EOT
Environment: ${var.environment}

%{ if var.environment == "prod" }
Production environment
%{ else }
Non-production environment
%{ endif }
EOT
```

---

# 36. Heredoc

複数行StringにはHeredocを利用できます。

```hcl
locals {
  message = <<-EOT
    Terraform
    HCL
    Beginner
  EOT
}
```

`<<-`形式はIndentationを含むHeredocを扱いやすくするための形式です。

---

# 37. Function

TerraformにはBuilt-in Functionがあります。

一般形：

```hcl
function_name(argument1, argument2)
```

例：

```hcl
upper("terraform")
```

結果：

```text
"TERRAFORM"
```

---

## 37.1 よく使用するFunction

```hcl
lower("TERRAFORM")

upper("terraform")

length(["a", "b", "c"])

contains(["dev", "prod"], "prod")

toset(["dev", "staging", "prod"])

merge(
  {
    Environment = "dev"
  },
  {
    Project = "music-app"
  }
)

jsonencode({
  name    = "terraform"
  enabled = true
})
```

Functionをすべて暗記する必要はなく、「式の中で値を加工するときにFunctionを利用できる」と理解しておけば十分です。

---

# 38. Meta-Arguments

Meta-ArgumentはTerraform Languageに組み込まれている特殊なArgumentです。

現行Terraformの公式Meta-Arguments Overviewでは、

```text
depends_on
count
for_each
lifecycle
provider
providers
```

が定義されています。

---

# 39. count

同じResourceなどを複数管理するときに利用できます。

```hcl
resource "aws_s3_bucket" "example" {
  count = 2

  bucket = "example-${count.index}"
}
```

`count.index`は`0`から始まります。

```text
aws_s3_bucket.example[0]
aws_s3_bucket.example[1]
```

のように各Instanceを識別します。

`count`はResourceだけでなく、Data Source、Module、Ephemeral Resourceなどでも利用できます。

---

# 40. for_each

Keyを使って複数Instanceを管理するときに利用できます。

ResourceやModuleなどで一般的に使用する`for_each`は、

```text
map
または
set(string)
```

を受け取ります。

List/Tupleは自動的にはSetへ変換されないため、必要であれば`toset()`などで明示的に変換します。

例：

```hcl
locals {
  bucket_types = toset([
    "assets",
    "logs"
  ])
}

resource "aws_s3_bucket" "example" {
  for_each = local.bucket_types

  bucket = "example-${each.value}"
}
```

Setの場合、

```text
each.key
each.value
```

は同じ値になります。

Instanceは、

```text
aws_s3_bucket.example["assets"]
aws_s3_bucket.example["logs"]
```

のようにKeyで識別されます。

---

# 41. countとfor_eachの違い

概念的には、

```text
count
→ Integer Indexで管理
→ [0]
→ [1]

for_each
→ Keyで管理
→ ["assets"]
→ ["logs"]
```

です。

ほぼ同一のInstanceを複数作成する場合は`count`、Instanceごとに意味のあるKeyや異なる設定値を持つ場合は`for_each`が適しています。

同一のBlockで`count`と`for_each`を同時に使用することはできません。

---

# 42. lifecycle

ResourceのLifecycleを制御できます。

```hcl
resource "example_resource" "example" {
  lifecycle {
    prevent_destroy = true
  }
}
```

代表的なRuleには、

```text
create_before_destroy
prevent_destroy
ignore_changes
replace_triggered_by
precondition
postcondition
action_trigger
```

などがあります。

なお、`prevent_destroy = true`でも、Resource Block自体をConfigurationから削除した場合のDestroyまでは防げない点に注意が必要です。

---

## 42.1 action_trigger

Terraform v1.15.xの`lifecycle`では、条件に応じてProvider-defined Actionを呼び出す`action_trigger`も利用できます。

これは`lifecycle`のRuleであり、`depends_on`などと同列のトップレベルMeta-Argumentではありません。

入門段階では存在を理解する程度で十分です。

---

# 43. providerとproviders

`provider` Meta-Argumentは、Resourceなどに対して使用するProvider Configurationを明示的に指定するために利用します。

`providers` Meta-Argumentは主に`module`ブロックで使用し、Parent ModuleのProvider ConfigurationをChild Moduleへ渡します。

---

# 44. Dynamic Block

Dynamic Blockは、繰り返し可能なNested Blockを動的に生成する仕組みです。

概念例：

```hcl
dynamic "rule" {
  for_each = var.rules

  content {
    name = rule.value.name
  }
}
```

重要なのは、

```text
for Expression
→ 値を生成・変換する

dynamic Block
→ Nested Blockを生成する
```

という違いです。

Dynamic Blockを多用するとConfigurationが読みづらくなることがあるため、固定Blockで十分な場合には固定Blockを優先します。

---

# 45. Module

Terraform Moduleは、同一ディレクトリにまとめられたTerraform Configurationの集合です。

Terraformを実行しているWorking DirectoryのModuleをRoot Moduleと呼びます。

`module`ブロックから呼び出すModuleをChild Moduleと呼びます。

```text
root/
├─ main.tf
├─ variables.tf
└─ modules/
   └─ s3-bucket/
      ├─ main.tf
      ├─ variables.tf
      └─ outputs.tf
```

---

## 45.1 Child Moduleの呼び出し

Root Module：

```hcl
module "storage" {
  source = "./modules/s3-bucket"

  bucket_name = local.bucket_name
}
```

Child Module：

```hcl
variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
```

Root Moduleから、

```hcl
module.storage.bucket_arn
```

と参照できます。

---

# 46. Sensitive Value

CredentialやPasswordなど、通常のCLI出力で値を表示したくない場合、

```hcl
variable "database_password" {
  type      = string
  sensitive = true
}
```

とできます。

Outputも、

```hcl
output "password" {
  value     = var.database_password
  sensitive = true
}
```

とできます。

ただし、

```text
sensitive = true
```

は値をStateから削除する機能ではありません。

Sensitive Variableの値はStateへ保存される場合があります。

さらに`terraform output -json`、`-raw`、またはSensitive Outputを名前で直接取得した場合には値が表示されるため注意が必要です。

---

# 47. Ephemeral Value

StateやPlanへ値を保存したくない場合にはEphemeralの仕組みがあります。

```hcl
variable "api_token" {
  type      = string
  sensitive = true
  ephemeral = true
}
```

概念的には、

```text
sensitive
→ 表示を隠す

ephemeral
→ Plan / Stateへ値を永続化しない
```

という違いです。

Ephemeral OutputはChild Moduleでは利用できますが、Root ModuleのOutputへ`ephemeral = true`を指定することはできません。

---

# 48. Ephemeral Resource

Terraform 1.10以降ではProviderが対応している場合にEphemeral Resourceを利用できます。

例としてRandom Providerなどでは、一時的なPasswordを生成するEphemeral Resourceがあります。

```hcl
ephemeral "random_password" "database" {
  length = 16
}
```

この例を利用する場合は、`hashicorp/random` Providerが別途必要です。

Ephemeral Resourceは通常のResourceとは異なり、その結果をPlanやStateへ保存しません。

---

# 49. Unknown Value

`terraform plan`時点では値が確定せず、Apply後に初めて確定する値があります。

CLIでは、

```text
(known after apply)
```

と表示される場合があります。

Terraformはこのような値をUnknown Valueとして扱い、値がまだ確定していなくても依存関係を含めたPlanを構築できます。

---

# 50. Terraform Configurationのファイル構成

実務では例えば、

```text
terraform/
├─ versions.tf
├─ providers.tf
├─ variables.tf
├─ data.tf
├─ locals.tf
├─ main.tf
├─ outputs.tf
└─ terraform.tfvars
```

のように分割できます。

ただし、この分割は必須ではありません。

Terraformは同一Directory直下の`.tf`ファイルを一つのModuleとして扱います。

---

# 51. .terraform.lock.hcl

`terraform init`を実行すると、

```text
.terraform.lock.hcl
```

が生成されます。

現在、Dependency Lock FileはProvider DependencyのVersion SelectionとChecksumなどを記録します。

HashiCorpは`.terraform.lock.hcl`をVersion Controlへ含めることを推奨しています。

重要なのは、

```text
*.tf
→ Terraform Configuration

.terraform.lock.hcl
→ Dependency Lock File
```

という違いです。

`.terraform.lock.hcl`はHCLの低レベル構文を利用しますが、Terraform Configuration Fileではありません。

---

# 52. terraform fmt

ConfigurationをTerraform標準形式へ整形します。

```bash
terraform fmt
```

Subdirectoryも対象にする場合、

```bash
terraform fmt -recursive
```

を使用します。

`terraform fmt`はTerraform公式のCanonical FormatとStyleに合わせてConfigurationを整形します。

---

# 53. terraform validate

ConfigurationのSyntaxや内部整合性を検証します。

```bash
terraform validate
```

ProviderやModuleが必要なConfigurationでは、事前にWorking DirectoryをInitializeする必要があります。

通常：

```bash
terraform init
```

Validationだけを行いBackendへ接続したくない場合：

```bash
terraform init -backend=false
```

も利用できます。

重要なのは、

```text
terraform validate
≠ AWS API上で実際に作成できることの保証
```

という点です。

`validate`はRemote ServiceやProvider APIそのものを検証するコマンドではありません。特定のWorkspaceやVariableを含めた実行Contextを確認するには`terraform plan`を使用します。

---

# 54. Terraform Style

HashiCorpのStyle Guideでは、例えば、

```text
Variableにはtypeとdescriptionを付ける
Outputにはdescriptionを付ける
VariableやLocal Valuesを過剰に使用しない
依存するResourceを参照元の後に配置する
countやfor_eachを必要以上に使用しない
terraform fmtを利用する
```

などが推奨されています。

---

# 55. 実装：AWS S3 Bucketを作成する

ここから実際のTerraform Configurationを作成します。

完成形：

```text
terraform-hcl-beginner/
├─ versions.tf
├─ providers.tf
├─ variables.tf
├─ data.tf
├─ locals.tf
├─ main.tf
├─ outputs.tf
└─ terraform.tfvars.example
```

2026年8月16日時点でTerraform公式Documentationはv1.15.xをlatestとしており、Terraform RegistryのHashiCorp AWS Providerはv6.60.0をlatestとして掲載しています。

教材ではProviderの6.x系を利用します。

---

# 56. versions.tf

```hcl
terraform {
  required_version = ">= 1.15.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

この設定では、

```text
Terraform CLI
→ 1.15.0以上、2.0.0未満

AWS Provider
→ 6.x
```

を対象とします。

---

# 57. providers.tf

```hcl
provider "aws" {
  region = var.aws_region
}
```

CredentialはTerraform Configurationへ直接ハードコードしません。

AWS ProviderはAWS CLIと共通するCredentialの仕組みを利用でき、公式Get Startedでも環境変数などを使ってCredentialを設定する方法が案内されています。

例えば、

```hcl
access_key = "..."
secret_key = "..."
```

をGit管理するConfigurationへ直接記述する方法は避けます。

---

# 58. variables.tf

```hcl
variable "project_name" {
  type        = string
  description = "Project name"
  default     = "terraform-hcl-beginner"

  validation {
    condition = (
      length(var.project_name) >= 3 &&
      length(var.project_name) <= 30 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project_name))
    )

    error_message = "project_name must be 3-30 characters, use lowercase letters, numbers, or hyphens, and start and end with a letter or number."
  }
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )

    error_message = "environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "ap-northeast-1"
}
```

---

# 59. data.tf

AWS Account IDを取得します。

```hcl
data "aws_caller_identity" "current" {}
```

参照：

```hcl
data.aws_caller_identity.current.account_id
```

---

# 60. locals.tf

```hcl
locals {
  bucket_name = join(
    "-",
    [
      "tfhcl",
      var.project_name,
      var.environment,
      data.aws_caller_identity.current.account_id
    ]
  )

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

S3 General Purpose Bucketの名前には、長さや利用可能文字、先頭・末尾文字などの制約があります。また通常のGeneral Purpose Bucket名はAWS Partition内で一意である必要があります。

この教材では、

```text
tfhcl-<project>-<environment>-<AWS Account ID>
```

という形式にすることで衝突しにくくしています。

ただし、Account IDを文字列として含めても**Bucket名のグローバルな一意性が数学的に保証されるわけではありません**。すでに同名Bucketが存在する場合は`project_name`などを変更してください。

---

# 61. main.tf

```hcl
resource "aws_s3_bucket" "example" {
  bucket = local.bucket_name

  tags = local.common_tags
}
```

`aws_s3_bucket`はAWS Providerが提供するGeneral Purpose S3 Bucket用Resourceです。

この短いコードでも、

```text
resource Block
Argument
Expression
Local Value Reference
Variable
Data Source
Map
```

など複数のTerraform Language機能が組み合わされています。

---

# 62. outputs.tf

```hcl
output "bucket_name" {
  description = "Created S3 bucket name"
  value       = aws_s3_bucket.example.bucket
}

output "bucket_arn" {
  description = "Created S3 bucket ARN"
  value       = aws_s3_bucket.example.arn
}
```

---

# 63. terraform.tfvars.example

```hcl
project_name = "terraform-hcl-beginner"
environment  = "dev"
aws_region   = "ap-northeast-1"
```

使用する場合はコピーします。

```bash
cp terraform.tfvars.example terraform.tfvars
```

Sensitiveな値をVariable Definition Fileへ書く場合は、そのファイルをVersion Controlへ登録しないよう注意します。Terraform公式もSensitive Valueを含むVariable Definition FileをVCSから除外することを推奨しています。

---

# 64. Initialize

```bash
terraform init
```

ProviderなどがDownloadされ、

```text
.terraform/
.terraform.lock.hcl
```

などが生成されます。

Working DirectoryはTerraform Operationを行う前にInitializeする必要があります。

---

# 65. Format

```bash
terraform fmt -recursive
```

ConfigurationをTerraform標準形式へ整形します。

---

# 66. Validation

```bash
terraform validate
```

Configurationに問題がなければ、

```text
Success! The configuration is valid.
```

という形式の成功結果が表示されます。

---

# 67. Plan

```bash
terraform plan
```

`terraform plan`はExecution Planを生成し、TerraformがInfrastructureへどのような変更を加える予定なのかを確認するためのコマンドです。

---

# 68. Apply

単純に、

```bash
terraform apply
```

を実行すると、Terraformは**新しいExecution Planを生成したうえで**確認を求め、そのPlanをApplyします。

そのため、

```bash
terraform plan
```

で先ほど見たPlanと、

```bash
terraform apply
```

で実際に使われるPlanが完全に同一であることは保証されません。

確認したPlanそのものを保存してApplyしたい場合は、

```bash
terraform plan -out=tfplan
```

としてPlan Fileを保存し、

```bash
terraform apply tfplan
```

を実行します。

---

# 69. Outputを確認する

```bash
terraform output
```

例えば、

```text
bucket_name = "tfhcl-terraform-hcl-beginner-dev-123456789012"
bucket_arn  = "arn:aws:s3:::tfhcl-terraform-hcl-beginner-dev-123456789012"
```

のようにRoot ModuleのOutputを確認できます。

---

# 70. Resourceを削除する

学習が終了したら、

```bash
terraform destroy
```

でTerraformが管理しているInfrastructureを削除します。Terraform公式Get Startedでも、不要になったResourceの削除には`terraform destroy`を利用します。

S3 Bucket内にObjectが存在する場合などは、そのResourceの設定やProviderの制約によって削除に失敗することがあります。

---

# 71. for_eachを実装する

次に複数Bucketを作成します。

```hcl
locals {
  bucket_types = toset([
    "assets",
    "logs"
  ])
}
```

Resource：

```hcl
resource "aws_s3_bucket" "multiple" {
  for_each = local.bucket_types

  bucket = join(
    "-",
    [
      "tfhcl",
      var.project_name,
      var.environment,
      each.value,
      data.aws_caller_identity.current.account_id
    ]
  )

  tags = merge(
    local.common_tags,
    {
      Purpose = each.value
    }
  )
}
```

Terraformでは、

```text
aws_s3_bucket.multiple["assets"]
aws_s3_bucket.multiple["logs"]
```

というInstanceとして管理されます。

ここでは、

```text
Set
for_each
each.value
join()
merge()
Local Values
Data Source
```

をまとめて確認できます。

---

# 72. Moduleへ分割する

構成：

```text
terraform-hcl-beginner/
├─ versions.tf
├─ providers.tf
├─ variables.tf
├─ data.tf
├─ locals.tf
├─ main.tf
├─ outputs.tf
└─ modules/
   └─ s3-bucket/
      ├─ main.tf
      ├─ variables.tf
      └─ outputs.tf
```

---

## 72.1 modules/s3-bucket/variables.tf

```hcl
variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "tags" {
  type        = map(string)
  description = "Tags for S3 bucket"
  default     = {}
}
```

---

## 72.2 modules/s3-bucket/main.tf

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = var.tags
}
```

---

## 72.3 modules/s3-bucket/outputs.tf

```hcl
output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.this.arn
}
```

---

# 73. Root ModuleからChild Moduleを呼び出す

```hcl
module "storage" {
  source = "./modules/s3-bucket"

  bucket_name = local.bucket_name
  tags        = local.common_tags
}
```

Root Output：

```hcl
output "bucket_name" {
  description = "Created S3 bucket name"
  value       = module.storage.bucket_name
}

output "bucket_arn" {
  description = "Created S3 bucket ARN"
  value       = module.storage.bucket_arn
}
```

値の流れは、

```text
Root Input Variable
        ↓
Root Local Value
        ↓
module Block
        ↓
Child Input Variable
        ↓
Child Resource
        ↓
Child Output
        ↓
module.storage.bucket_arn
        ↓
Root Output
```

となります。

---

# 74. movedブロック

すでに、

```hcl
resource "aws_s3_bucket" "example"
```

として管理しているResourceを、

```text
module.storage.aws_s3_bucket.this
```

へRefactoringした場合、Terraform上のAddressが変わります。

その場合、

```hcl
moved {
  from = aws_s3_bucket.example
  to   = module.storage.aws_s3_bucket.this
}
```

と記述できます。

`moved`ブロックは、以前のAddressと新しいAddressの関係をTerraformへ伝えるためのConfigurationです。

---

# 75. importブロック

すでにAWS上に存在するResourceをTerraform管理へ追加する場合、

```hcl
import {
  to = aws_s3_bucket.example
  id = "existing-bucket-name"
}
```

のように記述できます。

対応するResource Configurationも必要です。

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "existing-bucket-name"
}
```

通常は、

```bash
terraform plan
```

でImport内容を確認し、

```bash
terraform apply
```

でImportします。

---

# 76. removedブロック

Terraformによる管理から外しながら、実際のInfrastructureは残したい場合、

```hcl
removed {
  from = aws_s3_bucket.example

  lifecycle {
    destroy = false
  }
}
```

とできます。

`destroy = false`を指定すると、Terraform Stateから管理対象を外しますが、実際のInfrastructureはDestroyしません。

---

# 77. checkブロック

Infrastructureの状態を検証するために`check`ブロックを使用できます。

```hcl
check "bucket_name_length" {
  assert {
    condition     = length(local.bucket_name) <= 63
    error_message = "S3 bucket name is too long."
  }
}
```

`check`ブロックのAssertionが失敗した場合、TerraformはWarningを報告しますが、Operation自体は継続します。

したがって、

```text
条件を満たさない場合にOperationを止めたい
→ Variable Validation
→ precondition
→ postcondition など

Operationを止めずにInfrastructureを検証したい
→ check
```

という違いがあります。

---

# 78. actionブロック

Terraform v1.15.xにはProvider-defined Actionを表現する`action`ブロックがあります。

例えば、対応するAWS ProviderとLambda Functionが存在する場合、

```hcl
action "aws_lambda_invoke" "example" {
  config {
    function_name = "example-function"

    payload = jsonencode({
      source = "terraform"
    })
  }
}
```

のようなActionを定義できます。

`action`は通常のResource CRUDとは別のProvider-defined Operationを実行するための仕組みです。

入門段階では存在を理解する程度で十分です。

---

# 79. Query Fileとlistブロック

Terraform v1.15.xでは通常の`.tf`とは別に、

```text
*.tfquery.hcl
```

というQuery Configuration Fileがあります。

`terraform query`コマンドは`.tfquery.hcl`ファイルを読み込み、既存InfrastructureのResourceを検索してBulk Importなどに利用できます。

Query Fileでは、

```hcl
list "<RESOURCE_TYPE>" "example" {
  provider = <PROVIDER>
}
```

という`list`ブロックを使用します。

`list`ブロックは通常の`.tf`へ書くConfiguration Blockではなく、`.tfquery.hcl`専用です。

この機能は通常のHCL/Terraform入門では後回しで問題ありません。
