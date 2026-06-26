
build.gradle

```groovy
//Generate or Update Dictionaries for HTML
tasks.register('dictionariesToExcel', com.sqlapp.gradle.plugins.UpdateDictionariesTask){
	withSchema = { menuName -> true } //menuName=schemas or tables or columns or etc
	targetFile = file("schemas/baseline/${schema_level}.xml")
	directory = file("src/main/dictionaries/yaml")
	outputDirectory = file("src/main/dictionaries/xlsx")
	fileType = "xlsx"
}

tasks.register('dictionariesToYaml', com.sqlapp.gradle.plugins.UpdateDictionariesTask){
	withSchema = { menuName -> true } //menuName=schemas or tables or columns or etc
	targetFile = file("schemas/baseline/${schema_level}.xml")
	directory = file("src/main/dictionaries/xlsx")
	outputDirectory = file("src/main/dictionaries/yaml")
	fileType = "yaml"
}
```