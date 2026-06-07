# sqlapp-gradle-example

## 概要

このプロジェクトは、DB管理ツールである **sqlapp** のサンプルプロジェクトです。

主に以下の機能を試すことができます。

このプロジェクトは、DB管理ツールである **sqlapp** のサンプルプロジェクトです。
サンプルはHSQLDBで動くようになっているため、DBの用意は不要です。

主に以下の機能を試すことができます。

1. DBのスキーマ情報をXMLファイルとして出力する
2. スキーマ情報のXMLからER図を含むHTMLドキュメントを生成する
3. DBのスキーマの差分のDDL実行をする。
4. DBのテストデータ生成用の雛形ファイルの生成と、テストデータの生成を行う。

## 動作環境

* Java 17以降
* Gradle 9.5.1以降
* Graphviz（HTMLドキュメント生成時に利用）
* Docker（generateHtml.sh / generateHtml.bat利用時）

## サポートDB

sqlappは以下を含む多くのDBMSに対応しています。

* PostgreSQL
* SQL Server
* Oracle Database
* MySQL
* MariaDB
* DB2
* HSQLDB
* H2 Database
* SQLite
* SAP HANA
* CockroachDB
* その他JDBC対応DB

## 類似プロダクトとの比較

DBのスキーマ情報をHTMLドキュメントとして出力するツールには、[SchemaSpy Official Site](https://schemaspy.org/?utm_source=chatgpt.com) や [SchemaCrawler Official Site](https://www.schemacrawler.com/?utm_source=chatgpt.com) があります。

sqlappは、取得可能なDBオブジェクトの種類が豊富であり、特にDBMS固有機能への対応範囲が広いことが特徴です。

| サポートするオブジェクト | sqlapp | SchemaSpy | SchemaCrawler |
| -------------------------------- | :------: | :---------: | :-------------: |
| Table                            | ✓     | ✓        | ✓            |
| View                             | ✓     | ✓        | ✓            |
| Relations                        | ✓     | ✓        | ✓            |
| Index                            | ✓     | ✓        | ✓            |
| Index (Include Column)           | ✓     | -         | -             |
| Index (Where)                    | ✓     | -         | -             |
| Unique Constraints               | ✓     | ✓        | ✓            |
| Check Constraints                | ✓     | -         | -             |
| Exclude Constraints (PostgreSQL) | ✓     | -         | -             |
| Partitioning                     | ✓     | -         | -             |
| Sequence                         | ✓     | ✓        | ✓            |
| Inherits (PostgreSQL)            | ✓     | -         | -             |
| Procedure                        | ✓     | ✓        | ✓            |
| Function                         | ✓     | ✓        | ✓            |
| Event                            | ✓     | -         | -             |
| Synonym                          | ✓     | -         | ✓            |
| Rule                             | ✓     | -         | -             |
| Domain                           | ✓     | -         | ✓            |
| Type                             | ✓     | -         | ✓            |
| Trigger                          | ✓     | -         | ✓            |
| User                             | ✓     | -         | -             |
| Role                             | ✓     | -         | -             |
| Privilege                        | ✓     | -         | ✓            |


## ディレクトリ構成

```text
root/
 ├ gradle/
 ├ html/                 <- DBスキーマドキュメントの出力先
 ├ lib/                  <- 依存ライブラリ配置用ディレクトリ
 ├ schemas/              <- DBスキーマXML格納ディレクトリ
 │ └ base/               <- ベーススキーマ格納ディレクトリ
 │                         上位バージョンとの差分比較に利用
 ├ src/
 │ └ main/
 │   ├ config/
 │   │ └ local/
 │   │   └ jdbcConfig.properties <- DB接続設定
 │   ├ dictionaries/
 │   │   <- ドキュメント用の論理名・説明情報
 │   ├ export/
 │   │   <- データImport/Export用ディレクトリ
 │   ├ foreignkey/
 │   │   └ fkey.def
 │   │      <- 論理リレーション定義
 │   ├ generator/
 │   │   <- テストデータ生成定義
 │   ├ sqlup/
 │   │   <- DDL 差分管理(バージョンアップ)
 │   ├ sqldown/
 │   │   <- DDL 差分管理(バージョンダウン
 │   └ sql/
 │       <- タスク実行時に利用するSQL
 ├ build.gradle          <- Gradleビルド定義
 ├ Dockerfile            <- Graphvizを含むDockerイメージ定義
 ├ generateHtml.bat      <- Windows用HTML生成スクリプト
 ├ generateHtml.sh       <- Linux/macOS用HTML生成スクリプト
 ├ gradle.properties     <- Gradle設定
 ├ gradlew               <- Gradleラッパー (Linux/macOS)
 └ gradlew.bat           <- Gradleラッパー (Windows)
```

## Gradleタスク

### 基本タスク

#### exportXml

DBのスキーマ情報をXMLとして出力します。

出力先：

```text
schemas/
```

#### mvXml

exportXmlで出力したXMLファイルをベーススキーマとして配置します。

配置先：

```text
schemas/base/
```

#### generateHtml

スキーマXMLからER図を含むHTMLドキュメントを生成します。

Graphvizが必要なため、通常は以下のスクリプトを利用します。

* Linux/macOS: generateHtml.sh
* Windows: generateHtml.bat

事前に以下を実行してDBスキーマのXMLファイルを生成して所定のディレクトリに格納する必要があります。

```bash
gradlew exportXml
gradlew mvXml
```

Graphvizがインストールされた環境では、以下のgraldeのタスクでHTMLを生成することも出来ます。

```bash
gradlew generateHtml
```


#### updateDictionaries

HTML生成時に利用する論理名・説明情報を管理するファイルを生成します。ここに記載した情報はgenerateHtmlで生成されるHTMLに反映されます。

DBスキーマ変更後は以下の順に実行してください。

```bash
gradlew exportXml
gradlew mvXml
gradlew updateDictionaries
```

### スキーマ差分

#### diffSchemaXml

```text
schemas/
```

と

```text
schemas/base/
```

のスキーマXMLを比較し、差分を出力します。

```bash
gradlew diffSchemaXml
```

### スキーマバージョン管理

#### versionUp

DBスキーマを次のバージョンへ更新します。

```bash
gradlew versionUp
```

```bash
change_number  | applied_by | applied_at          | status    | description                         | series_number  | SQL(up) | SQL(down) | migration
=======================================================================================================================================================
               |            |                     | Initial   |                                     |                |         |           |
20260101112150 | root       | 2026-06-06 17:51:54 | Completed | create_table_products               | 20260101112150 | 1       | 1         |
20260102034455 | root       | 2026-06-06 17:51:54 | Completed | create_table_product_prices         | 20260101112150 | 1       | 1         |
20260103052000 | root       | 2026-06-06 17:51:54 | Completed | create_table_tax_rates              | 20260101112150 | 1       | 1         |
20260104150031 | root       | 2026-06-06 17:51:54 | Completed | create_table_warehouses             | 20260101112150 | 1       | 1         |
20260105101033 | root       | 2026-06-06 17:51:54 | Completed | create_table_inventory_balances     | 20260101112150 | 1       | 1         |
20260106091144 | root       | 2026-06-06 17:51:54 | Completed | create_table_inventory_transactions | 20260101112150 | 1       | 1         |
20260107081255 | root       | 2026-06-06 17:51:54 | Completed | create_table_payment_terms          | 20260101112150 | 1       | 1         |
20260108082356 | root       | 2026-06-06 17:51:54 | Completed | create_table_customers              | 20260101112150 | 1       | 1         |
20260109111201 | root       | 2026-06-06 17:51:54 | Completed | create_table_sales_returns          | 20260101112150 | 1       | 1         |
20260110121111 | root       | 2026-06-06 17:51:54 | Completed | create_table_sales_return_details   | 20260101112150 | 1       | 1         |
20260602101156 | root       | 2026-06-06 17:51:54 | Completed | create_table_accounts_receivable    | 20260101112150 | 1       | 1         |
20260603114111 | root       | 2026-06-06 17:51:54 | Completed | create_table_orders                 | 20260101112150 | 1       | 1         |
20260604153122 | root       | 2026-06-06 17:51:54 | Completed | create_table_order_details          | 20260101112150 | 1       | 1         |
20260605183132 | root       | 2026-06-06 17:51:54 | Completed | create_table_shipments              | 20260101112150 | 1       | 1         |
20260606160101 | root       | 2026-06-06 17:51:54 | Completed | create_table_shipment_details       | 20260101112150 | 1       | 1         |
20260607110135 | root       | 2026-06-06 17:51:54 | Completed | create_table_invoices               | 20260101112150 | 1       | 1         |
20260608110155 | root       | 2026-06-06 17:51:54 | Completed | create_table_invoice_details        | 20260101112150 | 1       | 1         |
20260609102145 | root       | 2026-06-06 17:52:09 | Completed | create_table_receipts               | 20260609102145 | 1       | 1         |
20260610092033 | root       | 2026-06-06 17:52:09 | Completed | create_table_receipt_allocations    | 20260609102145 | 1       | 1         | <= current
```

#### versionDown

DBスキーマを前のバージョンへ戻します。不用意なバージョンダウンをさせないために、サンプルではコメントになっています。

```bash
gradlew versionDown
```

```
********************** execute version sql. **********************
versionNumber=20260610092033
******************************************************************
Database status.
change_number  | applied_by | applied_at          | status    | description                         | series_number  | SQL(up) | SQL(down) | migration
=======================================================================================================================================================
               |            |                     | Initial   |                                     |                |         |           |
20260101112150 | root       | 2026-06-06 17:51:54 | Completed | create_table_products               | 20260101112150 | 1       | 1         |
20260102034455 | root       | 2026-06-06 17:51:54 | Completed | create_table_product_prices         | 20260101112150 | 1       | 1         |
20260103052000 | root       | 2026-06-06 17:51:54 | Completed | create_table_tax_rates              | 20260101112150 | 1       | 1         |
20260104150031 | root       | 2026-06-06 17:51:54 | Completed | create_table_warehouses             | 20260101112150 | 1       | 1         |
20260105101033 | root       | 2026-06-06 17:51:54 | Completed | create_table_inventory_balances     | 20260101112150 | 1       | 1         |
20260106091144 | root       | 2026-06-06 17:51:54 | Completed | create_table_inventory_transactions | 20260101112150 | 1       | 1         |
20260107081255 | root       | 2026-06-06 17:51:54 | Completed | create_table_payment_terms          | 20260101112150 | 1       | 1         |
20260108082356 | root       | 2026-06-06 17:51:54 | Completed | create_table_customers              | 20260101112150 | 1       | 1         |
20260109111201 | root       | 2026-06-06 17:51:54 | Completed | create_table_sales_returns          | 20260101112150 | 1       | 1         |
20260110121111 | root       | 2026-06-06 17:51:54 | Completed | create_table_sales_return_details   | 20260101112150 | 1       | 1         |
20260602101156 | root       | 2026-06-06 17:51:54 | Completed | create_table_accounts_receivable    | 20260101112150 | 1       | 1         |
20260603114111 | root       | 2026-06-06 17:51:54 | Completed | create_table_orders                 | 20260101112150 | 1       | 1         |
20260604153122 | root       | 2026-06-06 17:51:54 | Completed | create_table_order_details          | 20260101112150 | 1       | 1         |
20260605183132 | root       | 2026-06-06 17:51:54 | Completed | create_table_shipments              | 20260101112150 | 1       | 1         |
20260606160101 | root       | 2026-06-06 17:51:54 | Completed | create_table_shipment_details       | 20260101112150 | 1       | 1         |
20260607110135 | root       | 2026-06-06 17:51:54 | Completed | create_table_invoices               | 20260101112150 | 1       | 1         |
20260608110155 | root       | 2026-06-06 17:51:54 | Completed | create_table_invoice_details        | 20260101112150 | 1       | 1         |
20260609102145 | root       | 2026-06-06 17:52:09 | Completed | create_table_receipts               | 20260609102145 | 1       | 1         | <= current
20260610092033 |            |                     | Pending   | create_table_receipt_allocations    |                | 1       | 1         |
```

#### versionRepair

スキーマバージョン管理情報を修復します。

### DBデータ Import / Export

#### importData

Excel、CSV、TSV、XMLなどの複数ファイルをDBへ一括インポートします。Foreign Key制約を考慮して、生成は依存関係のないテーブルからimportします。

```bash
gradlew importData
```

#### exportData

DBのテーブルデータをExcel、CSV、TSV、XMLなどへ一括エクスポートします。

```bash
gradlew exportData
```

### DBテストデータ生成

#### generateDataGeneratorSetting

テストデータ生成定義の雛形を生成します。

DBに接続して生成し、生成された設定ファイルを編集して利用します。
テストデータ生成用の定義ファイルは必要に応じて修正する事が出来ます。
以下の順でコマンドを実行すると、試しに動かすことが出来ます。

```bash
gradlew versionUp
gradlew generateDataGeneratorSetting
gradlew generateData
```

#### generateData

テストデータ生成定義に従い、DBへテストデータを投入します。Foreign Key制約を考慮して、生成は依存関係のないテーブルから実行します。

```bash
gradlew generateData
```

サンプルでは、src/main/java/data/generator配下に存在するクラスのスタティックメソッドを自動的に読みこむようにしてあるので、ここに追加したメソッドをhello()のように呼び出せます。

#### convertGeneratorSettingYaml

generateDataGeneratorSettingで生成したファイルをYAML形式に変換します。
EXCELの方がファイルの編集がしやすいですが、構成管理する場合はYAMLなどのテキストの方がやりやすいので、このタスクでYAML形式に変換します。

```bash
gradlew convertGeneratorSettingYaml
```

#### convertGeneratorSettingExcel

generateDataGeneratorSettingで生成したファイルをEXCEL形式に変換します。
YAMLで構成管理にしたファイルを編集する場合に、EXCELの方がファイルの編集がしやすいため、このタスクでExcel形式に変換します。

```bash
gradlew convertGeneratorSettingExcel
```

#### countAllTables

SELECT COUNT(*)を実行して全てのテーブルの件数を返します。

```bash
gradlew countAllTables
```

```bash
> Task :countAllTables
Registered driver with driverClassName=org.hsqldb.jdbc.JDBCDriver was not found, trying direct instantiation.
schemaName | tableName              | count
===========================================
PUBLIC     | ACCOUNTS_RECEIVABLE    | 100
PUBLIC     | CUSTOMERS              | 200
PUBLIC     | INVENTORY_BALANCES     | 200
PUBLIC     | INVENTORY_TRANSACTIONS | 200
PUBLIC     | INVOICES               | 100
PUBLIC     | INVOICE_DETAILS        | 100
PUBLIC     | ORDERS                 | 100
PUBLIC     | ORDER_DETAILS          | 100
PUBLIC     | PAYMENT_TERMS          | 200
PUBLIC     | PRODUCTS               | 200
PUBLIC     | PRODUCT_PRICES         | 200
PUBLIC     | RECEIPTS               | 100
PUBLIC     | RECEIPT_ALLOCATIONS    | 100
PUBLIC     | SALES_RETURNS          | 100
PUBLIC     | SALES_RETURN_DETAILS   | 100
PUBLIC     | SHIPMENTS              | 200
PUBLIC     | SHIPMENT_DETAILS       | 100
PUBLIC     | TAX_RATES              | 200
PUBLIC     | WAREHOUSES             | 200
PUBLIC     | changelog              | 19
```

### その他

* copyLib
* cleanLib
* deploy
* generateSql
* toExcel
* toJson
* toCsv

## 動作確認

本プロジェクトはHSQLDBを利用したサンプル構成になっています。

以下のコマンドを順番に実行することで動作確認できます。

```bash
gradlew versionUp
gradlew exportXml
gradlew mvXml
gradlew generateDataGeneratorSetting
gradlew generateData
```

HTMLドキュメント生成：

Linux/macOS

```bash
./generateHtml.sh
```

Windows

```bat
generateHtml.bat
```
