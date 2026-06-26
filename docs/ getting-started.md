

```text
root/
 ├ docs/
 ├ gradle/
 ├ html/                 <- Generated schema documentation
 ├ schemas/              <- Schema XML files
 │ ├ baseline/            <- Baseline schema
 │ └ current/             <- Current schema
 ├ src/
 │ └ main/
 │   ├ config/
 │   │ └ local/
 │   │   └ jdbcConfig.properties <- Database connection settings
 │   ├ dictionaries/ <- Logical names and descriptions used in documentation
 │   │  ├ excel/
 │   │  │ ├ table
 │   │  │ └
 │   │  ├ csv/
 │   │  ├ tsv/
 │   │  └ yaml/
 │   ├ export/ <- Data import/export files
 │   │  ├ csv/
 │   │  ├ tsv/
 │   │  ├ excel/
 │   │  ├ jsonl/
 │   │  └ yaml/
 │   ├ foreignkey/
 │   │  └ fkey.def <- Logical relationship definitions
 │   ├ generator/ <- Test data generation settings
 │   │  ├ excel
 │   │  ├ json
 │   │  ├ yaml
 │   │  └ generated/
 │   ├ java
 │   │  └ functions <-Contains custom Java static methods that can be invoked from MVEL expressions.
 │   ├ resources/
 │   └ sql/
 │      ├ up/  <- DDL files for schema version up
 │      ├ down/ <- DDL files for schema version down
 │      └ generated/
 ├ README.md             <- sqlapp README
 ├ build.gradle          <- Gradle build definition
 ├ gradle.properties     <- Gradle configuration
 ├ gradlew               <- Gradle Wrapper (Linux/macOS)
 └ gradlew.bat           <- Gradle Wrapper (Windows)
```