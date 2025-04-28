variable "database_name" {
  type        = string
  description = "The database you need to vacuum. Leave empty only if schedule_vacuum is false"
  default     = null
}

variable "vacuum_type" {
  type        = string
  description = "Whether we vacuum all table concurrently or sequentially. Sequentially will take longer. Concurrent is shorter but is more likely consume all your Athena DML quota, and steps might need retries"
  validation {
    condition     = contains(["concurrent", "sequential"], var.vacuum_type)
    error_message = "The vacuum type value must be one of [concurrent, sequential]."
  }
}

variable "schedule_vacuum" {
  type        = bool
  description = "Whether we should create a scheduler for the vacuum. If false, only the step function will be created"
  default     = true
}

variable "schedule" {
  type        = string
  description = "Schedule"
  default     = "cron(0 2 * * ? *)" // at 2AM UTC
}

variable "stepfunction_name" {
  type        = string
  description = "How you want the step function to be named"
  default     = "vacuum-iceberg-tables"
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