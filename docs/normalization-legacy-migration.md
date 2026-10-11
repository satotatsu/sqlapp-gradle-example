# Normalization and legacy-migration example

This page contains copyable Gradle configuration for sqlapp's normalization
and legacy-migration workflow. The authoritative property reference is in the
main sqlapp repository:

- [Normalization and legacy-migration task reference](https://github.com/satotatsu/sqlapp/blob/main/docs/gradle-plugin/normalization-and-legacy-migration.md)
- [All Gradle tasks](https://github.com/satotatsu/sqlapp/blob/main/docs/gradle-plugin/README.md)

The paths below are examples. Create the referenced PL/I, YAML, Schema XML, and
CSV files before running the corresponding task.

## 1. Import a PL/I structure

```groovy
pliSchemaImport {
    targetFile = file('src/main/pli/company.pli')
    configurationFile = file('src/main/normalization/company-pli-import.yaml')
    outputDirectory = file('build/legacy/imported')
    migrationMappingDirectory = file('build/legacy/mapping')
    encoding = 'UTF-8'
}
```

```shell
./gradlew pliSchemaImport
```

On Windows, replace `./gradlew` with `gradlew.bat`.

## 2. Generate normalization candidates

```groovy
generateNormalizationPlan {
    targetFile = file('build/legacy/imported/company.xml')
    foreignKeyDefinitionDirectory = file('src/main/foreignkey')
    migrationMappingFile =
        file('build/legacy/mapping/company-legacy-migration.yaml')
    outputDirectory = file('build/legacy/plan')
    minimumColumnCount = 2
    variableCharacterMinimumLength = 20L
    previewSchemaEnabled = true
    locale = 'en'
}
```

```shell
./gradlew generateNormalizationPlan
```

Review the candidate YAML instead of applying every suggestion mechanically.
Generate HTML documentation from both the imported Schema XML and the preview
Schema XML to compare table structure and ER diagrams.

## 3. Apply reviewed transformations

Column rules and first-normal-form conversion are independent stages and may be
run in the order appropriate for the reviewed plan.

```groovy
columnRuleTransform {
    targetFile = file('build/legacy/imported/company.xml')
    rulesFile = file('src/main/normalization/company-column-rules.yaml')
    outputDirectory = file('build/legacy/column-transformed')
    migrationMappingFile =
        file('build/legacy/mapping/company-legacy-migration.yaml')
    migrationMappingDirectory = file('build/legacy/mapping')
}

firstNormalForm {
    targetFile = file('build/legacy/column-transformed/company.xml')
    foreignKeyDefinitionDirectory = file('src/main/foreignkey')
    outputDirectory = file('build/legacy/normalized')
    migrationMappingFile =
        file('build/legacy/mapping/company-legacy-migration.yaml')
    migrationMappingDirectory = file('build/legacy/mapping')
    minimumColumnCount = 2
    convertCompositePrimaryKey = true
    surrogateKeyGenerationType =
        com.sqlapp.data.db.command.normalization.SurrogateKeyGenerationType.IDENTITY
}
```

```shell
./gradlew columnRuleTransform firstNormalForm
```

Use `SEQUENCE` instead of `IDENTITY` when required by the target database.
External virtual-FK definitions must be supplied to both the plan and
normalization tasks when the source Schema XML does not contain the logical
parent-child relationships. The normalized XML contains the rewritten virtual
relationships, so do not apply the original definitions again when generating
its HTML documentation.

## 4. Generate the migration contract and PL/I extractor

```groovy
generateLegacyMigrationContract {
    mappingFile =
        file('build/legacy/mapping/company-legacy-migration.yaml')
    outputDirectory = file('build/legacy/contract')
    encoding = 'UTF-8'
    delimiter = ','
    quote = '"'
    header = true
    recordSeparator = 'CRLF'
}

generatePliCsvExtractor {
    contractFile = file('build/legacy/contract/company-contract.yaml')
    outputDirectory = file('build/legacy/pli-extractor')
    programName = 'COMPANYX'
}
```

```shell
./gradlew generateLegacyMigrationContract generatePliCsvExtractor
```

Review and compile the generated PL/I in the host environment. The contract is
also usable when CSV extraction is implemented by another mechanism.

## 5. Generate and execute the RDB loader

```groovy
generateLegacyRdbLoader {
    contractFile = file('build/legacy/contract/company-contract.yaml')
    schemaFile = file('build/legacy/normalized/company.xml')
    outputDirectory = file('build/legacy/loader')
    tableOperationMode = 'INSERT_IGNORE'
    rootBatchSize = 500
    commitEveryRootBatches = 500L
    deleteCommittedRoots = true
    stagingTablePrefix = 'TMP_'
    rootCursorStrategy = 'DIALECT'
}

loadLegacyHierarchy {
    loadPlanFile = file('build/legacy/loader/load-plan.yaml')
    schemaFile = file('build/legacy/normalized/company.xml')
    dataSource {
        properties "${dataSourceProperties}"
    }
}
```

```shell
./gradlew generateLegacyRdbLoader
./gradlew loadLegacyHierarchy
```

`loadLegacyHierarchy` changes database data. First test the complete workflow
with representative CSV files and a disposable database.

## Optional viewpoint scope

The loader may restrict its generated plan to a logical schema viewpoint:

```groovy
generateLegacyRdbLoader {
    contractFile = file('build/legacy/contract/company-contract.yaml')
    schemaFile = file('build/legacy/normalized/company.xml')
    outputDirectory = file('build/legacy/loader')
    viewpointsFile = file('src/main/viewpoints/viewpoints.yaml')
    viewpointId = 'legacy-company-load'
    includeViewpointAncestors = true
}
```

Viewpoints remain logical views. Loader-specific hierarchy closure and safety
validation are applied while generating the load plan.
