to loop over 2 lists of values 


```hcl
locals{
 association-list =  flatten([
    for database, tables in var.tables_map : [
      for table in tables : {
        key = "${database}__${table}"
        value = {
          "table" = table
          "database" = database
          }
      }
    ]
 ])

 db_table_association_map = { for item in local.association-list: 
     item.key => item.value
   }
}
```