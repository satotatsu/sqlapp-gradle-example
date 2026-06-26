

build.gradle

```groovy
migration {
	debug = true
	dataSource {
		properties "${dataSourceProperties}"
	}
//	parameters = ['schemaNameSuffix':"${schemaNameSuffix}"]
	sqlDirectory     = file("src/main/sql/migration/up")
	downSqlDirectory = file("src/main/sql/migration/down")
	fileDirectory    = file("src/main/resources")
	encoding = "UTF8"
	lastChangeNumber = "${lastChangeToApply}"
	showVersionOnly = false
	withSeriesNumber = true
	placeholderPrefix = '${'
	placeholderSuffix = '}'
	placeholders = true
	changeTable {
//		name = "${masterSchemaName}.${changeLogTableName}"
//		idColumnName="id"
//		appliedByColumnName="applied_by"
//		appliedAtColumnName="complete_dt"
//		descriptionColumnName="description"
//		seriesNumberColumnName="seriesNumber"
	}
}
```