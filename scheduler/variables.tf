variable "database_name" {
  type        = string
  description = "The database you need to schedule vacuuming for"
}

variable "schedule" {
  type        = string
  description = "Schedule"
  default     = "cron(0 2 * * ? *)" // at 2AM UTC
}

variable "stepfunction_arn" {
  type        = string
  description = "StepFunction Arn to target"
}