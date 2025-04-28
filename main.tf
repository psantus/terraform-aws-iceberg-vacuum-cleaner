module "sequential" {
  count  = var.vacuum_type == "sequential" ? 1 : 0
  source = "./vacuum-sequential"

  athena_queries_bucket_name = var.athena_queries_bucket_name
  athena_queries_prefix      = var.athena_queries_prefix
  iceberg_table_bucket_name  = var.iceberg_table_bucket_name
  stepfunction_name          = var.stepfunction_name
}

module "concurrent" {
  count  = var.vacuum_type == "concurrent" ? 1 : 0
  source = "./vacuum-concurrent"

  athena_queries_bucket_name = var.athena_queries_bucket_name
  athena_queries_prefix      = var.athena_queries_prefix
  iceberg_table_bucket_name  = var.iceberg_table_bucket_name
  stepfunction_name          = var.stepfunction_name
}

module "scheduler" {
  count  = var.schedule_vacuum ? 1 : 0
  source = "./scheduler"

  database_name    = var.database_name
  stepfunction_arn = var.vacuum_type == "sequential" ? module.sequential[0].stepfunction_arn : module.concurrent[0].stepfunction_arn
  schedule         = var.schedule
}