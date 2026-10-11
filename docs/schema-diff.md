# Schema comparison and SQL generation

sqlapp compares two Schema XML files without requiring a live database. A
typical workflow exports the current database, compares it with a baseline, and
generates migration SQL.

## Compare Schema XML

The sample project configures the plugin-provided `diffSchemaXml` task:

```groovy
diffSchemaXml {
    originalFile = file("schemas/baseline/${schema_level}.xml")
    targetFile = file("schemas/current/${schema_level}.xml")
}
```

```shell
./gradlew diffSchemaXml
```

`originalFile` is the baseline and `targetFile` is the desired schema. Reversing
them reverses the meaning of additions and removals.

## Generate migration SQL

```groovy
generateDiffSql {
    originalFile = file("schemas/baseline/${schema_level}.xml")
    targetFile = file("schemas/latest/${schema_level}.xml")
    encoding = 'UTF8'
    outputAsMultiFiles = false
    withVersionDown = true
    outputDirectory = file('src/main/sql/generated')
    outputFileExtension = 'sql'
    changeNumberStep = 10
    numberOfDigits = 19

    schemaOptions {
        outputCommit = false
        dropIfExists = true
        createIfNotExists = true
        decorateSchemaName = false
        setSearchPathToSchema = true
    }
}
```

```shell
./gradlew generateDiffSql
```

Generated SQL depends on the selected database dialect. Review destructive
operations, identifier quoting, datatype changes, and version-down SQL before
execution.

