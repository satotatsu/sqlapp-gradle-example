
catalog

```text
Catalog(name,displayName,remarks,displayRemarks,collation,caseSensitive,characterSementics,characterSet)
 ├ Schemas
 │ └ Schema
 │   ├ Tables
 │   │ └ Table
 │   │   ├ Columns
 │   │   │ └ Column
 │   │   │ Rows
 │   │   │ └ Row
 │   │   ├ Constraints
 │   │   │ ├ UniqueConstraint
 │   │   │ │ └ Columns
 │   │   │ │   └ Column 
 │   │   │ ├ ForeignKeyConstraint
 │   │   │ │ ├ Columns
 │   │   │ │ │ └ Column 
 │   │   │ │ ├ RelatedTable
 │   │   │ │ └ RelatedColumns
 │   │   │ │   └ Column
 │   │   │ ├ CheckConstraint
 │   │   │ └ ExcludeConstraint
 │   │   ├ Indexes
 │   │   │ └ Index
 │   │   │   └ Columns
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 ├ Users
 │ └ User 
 ├ Roles
 │ └ Role
 ├ RolePrivileges
 │ └ RolePrivilege
 ├ RoleMembers
 │ └ RoleMember
 ├ TableSpaces
 │ └ TableSpace
 ├ ColumnPrivileges
 │ └ ColumnPrivilege
 ├ ObjectPrivileges
 │ └ ObjectPrivilege
 ├ PublicDbLinks
 │ └ PublicDbLink
 ├ Directories
 │ └ Directory
 ├ PublicSynonyms
 │ └ PublicSynonym
 ├ PartitionSchemes         <- for SQL Server
 │ └ PartitionScheme
 ├ PartitionFunctions       <- for SQL Server
 │ └ PartitionFunction
 ├ RoutinePrivileges
 │ └ RoutinePrivilege
 └ Settings
   └ Setting
```