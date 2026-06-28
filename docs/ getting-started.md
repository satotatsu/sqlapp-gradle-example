

```text
root/
 ├ docs/
 ├ gradle/
 ├ hsqltestdb/           <- Sample HSQL DB Directory
 ├ html/                 <- Generated schema documentation
 ├ schemas/              <- Schema XML files
 │ ├ baseline/           <- Baseline schema
 │ └ latest/             <- Latest schema
 ├ src/
 │ └ main/
 │   ├ config/
 │   │ └ local/
 │   │   └ jdbcConfig.properties <- Database connection settings
 │   ├ dictionaries/ <- Logical names and descriptions used in documentation
 │   │  │ ├ schemas.csv      <- Dictionary for 
 │   │  │ ├ tables.csv
 │   │  │ └ columns.csv
 │   │  ├ excel/
 │   │  │ ├ schemas.xlsx     <- Dictionary for Edit
 │   │  │ ├ tables.xlsx      <- Dictionary for Edit
 │   │  │ └ columns.xlsx     <- Dictionary for Edit
 │   ├ export/ <- Data import/export files
 │   │  ├ csv/
 │   │  ├ tsv/
 │   │  ├ excel/
 │   │  ├ jsonl/
 │   │  └ yaml/
 │   ├ foreignkey/
 │   │  └ fkey.def <- Logical relationship definitions
 │   ├ generator/ <- Test data generation settings
 │   │  ├ excel/
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