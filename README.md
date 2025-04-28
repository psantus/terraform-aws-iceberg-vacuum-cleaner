# AWS Iceberg Vacuum Cleaner
Automate Iceberg table vacuum using AWS Step Functions

## Usage

```hcl
module "vacuum_cleaner" {
  source = "psantus/terraform-aws-iceberg-vacuum-cleaner"

  database_name              = "my-datbase"
  vacuum_type                = "concurrent"
  iceberg_table_bucket_name  = "my-table-bucket"
  athena_queries_bucket_name = "my-table-bucket"
  athena_queries_prefix      = "athena-queries"
}
```

## What this module creates

* A Step Functions workflow that will vacuum your Iceberg tables either sequentially or concurrently
* A Cloudwatch Log group
* An Eventbridge scheduler (optional) to trigger the workflow 

## Disclaimer

Note that the license agreement explicitely states you're responsible for the use of this module. I, in particular,
cannot be held responsible for any cost incurred due to the use or mis-use of this module, whether those costs are
generated directly by the resources deployed by this module, or by WAF, should the process set up by this module fail
to protect you from those costs.