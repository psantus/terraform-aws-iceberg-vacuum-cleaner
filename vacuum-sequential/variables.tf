variable "stepfunction_name" {
  type        = string
  description = "How you want the step function to be named"
}

variable "iceberg_table_bucket_name" {
  type        = string
  description = "Name of the bucket where Iceberg table is stored"
}

variable "athena_queries_bucket_name" {
  type        = string
  description = "Name of the bucket where Athena will store query output"
}

variable "athena_queries_prefix" {
  type        = string
  description = "Prefix in the bucket where Athena will store query output"
}