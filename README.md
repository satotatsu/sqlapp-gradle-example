# sqlapp-gradle-example
## 概要
- このプロジェクトはDB管理ツールであるsqlappのサンプル用のプロジェクトです。このプロジェクトでは以下の事が出来ます。
  1. DBのスキーマ情報をXMLファイルとして出力する。
  1. スキーマ情報のXMLからER図を含めたドキュメントを生成する。

## 類似のプロダクトとの比較
- DBのスキーマ情報をHTMLとして出力するツールには[SchemaSpy](https://schemaspy.org/ "SchemaSpy")、[SchemaCrawler](https://www.schemacrawler.com/ "SchemaCrawler")などがありますが、SqlappはサポートするDBの機能の点でこれらのプロダクトよりも優れています。  
  
| サポートするオブジェクト |  Sqlapp | SchemaSpy | SchemaCrawler |
| ----  | ---- | ---- | ---- |
|  Table   |  OK  |  OK  |  OK  |
|  View   |  OK  |  OK  |  OK  |
|  Relations   |  OK  |  OK  |  OK  |
|  Index   |  OK  |  OK  |  OK  |
|  Index(Include Column)   |  OK  |  -  |  -  |
|  Index(Where)   |  OK  |  -  |  -  |
|  Unique Constraints   |  OK  |  OK  |  OK  |
|  Check Constraints   |  OK  |  -  |  -  |
|  Exclude Constraints(Postgres) |  OK  |  -  |  -  |
|  Partitioning   |  OK  |  -  |  -  |
|  Sequence   |  OK  |  OK  |  OK  |
|  Inherits(Postgres)   |  OK  |  -  |  -  |
|  Procedure   |  OK  |  OK  |  OK  |
|  Function   |  OK  |  OK  |  OK  |
|  Event   |  OK  |  -  |  -  |
|  Synonym   |  OK  |  -  |  OK  |
|  Rule   |  OK  |  -  |  -  |
|  Domain   |  OK  |  -  |  OK  |
|  Type   |  OK  |  -  |  OK  |
|  Trigger   |  OK  |  -  |  OK  |
|  User   |  OK  |  -  |  -  |
|  Role   |  OK  |  -  |  -  |
|  Privilege   |  OK  |  -  |  OK  |
  
## ディレクトリ構成

```
root/
　├ gradle/
　├ html/ <- DBのスキーマ情報のドキュメントの出力先
　├ lib/ <- 依存関係のあるライブラリを入れておくためのディレクトリ
　├ schemas/ <- DBのスキーマ格納用のディレクトリ
　│　└ base/ <- DBのスキーマのベースとなるバージョンファイルの格納用のディレクトリ。この上位に格納されたファイルとDIFFをとることが出来る。
　├ src/
　│　└ main/
　│　　　├ config/
　│　　　│ └ local/
　│　　　│　  └ jdbcConfig.properties <- DBの接続先情報
　│　　　├ export/ <- DBのデータのExport(or Import)先
　│　　　├ foreignkey/
　│　　　│　  └ fkey.def <- 物理的なリレーションがないが、論理的なリレーションをER図に反映するための定義のファイル
　│　　　└ sql/ <- 何かの処理を行うためのSQLを入れておくためのディレクトリ
　├ build.gradle <- gradleの定義ファイル
　├ Dockerfile <- gradleのgenerateHtmlタスクが依存するgraphvizをDocker環境で実行するためのファイル
　├ generateHtml.bat <- HTMLのドキュメント生成用のgradleタスクをDocker環境で行うためのコマンド(for Win)
　├ generateHtml.sh <- HTMLのドキュメント生成用のgradleタスクをDocker環境で行うためのコマンド(for Linux)
　├ gradle.properties <- gradleの設定ファイル
　├ gradlew <- gradleラッパーファイル(for Linux)
　└ gradlew.bat <- gradleの設定ファイル(for Win)
```

## gradleタスク
### 基本タスク
 - exportXml  
   DBのスキーマ情報をXMLファイルとして出力するタスク。schemas/配下に出力される。
 - mvXml  
   exportXmlで出力したXMLファイルをschemas/base配下に移動するだけのタスク。
 - generateHtml  
   schemas/base配下のXMLからHTMLのドキュメントを生成するためのタスク。graphvizが必要なので実際はgenerateHtml.batを利用してDocker環境で実行する。
 - updateDictionaries  
   generateHtmlで生成されるHTMLのテーブル、インデックス、カラムなどの論理名を記載するExcelファイルを生成するためのタスク。DBに変更があった場合は、exportXml、mvXml実効後でこのタスクを実行するとExcelが更新される。

### スキーマDIFF
 - diffSchemaXml  
   schemas/とschemas/base配下のDBスキーマのXMLファイルのDIFFを出力する。

### スキーマバージョン管理タスク
 - versionUp
 - versionDown
 - versionRepair

### DBデータImport、Export系
 - importData
 - exportData

### DBテストデータ生成
 - generateDataGeneratorSetting
   DBにデータを生成するための雛形となるファイルを生成するタスク。DBに接続して生成する。
 - generateData
   指定されたDB生成用のファイルからDBに接続してデータを生成するタスク。

### その他
 - copyLib
 - cleanLib
 - deploy
 - generateSql
 - toExcel
 - toJson
 - toCsv
