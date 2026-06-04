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

#### versionDown

DBスキーマを前のバージョンへ戻します。不用意なバージョンダウンをさせないために、サンプルではコメントになっています。

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
サンプルでは、src/main/java/data/generator配下に存在するクラスのスタティックメソッドを自動的に読みこむようにしてあるので、ここに追加したメソッドをhello()のように呼び出せます。

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
