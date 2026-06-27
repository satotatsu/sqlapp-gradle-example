
catalog

```text
Catalog
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
 │   │   ├ Inherits  <- for Postgres
 │   │   │  └ Inherits
 │   │   ├ Partitioning
 │   │   │  ├ PartitionScheme  <- for SQL Server
 │   │   │  │ ├ tableSpaces
 │   │   │  │ └ partitionFunction
 │   │   │  ├ TableSpaces
 │   │   │  ├ PartitioningColumns
 │   │   │  │ └ Column  
 │   │   │  ├ SubPartitioningColumns
 │   │   │  │ └ Column  
 │   │   │  └ Partitions
 │   │   │     └ Partition
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 │   │   │
 ├ Assemblies         <- for SQL Server
 │ └ Assembly
 │   └ AssemblyFiles
 │     └ AssemblyFile
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