# EventBridge Scheduler
resource "aws_scheduler_schedule" "vacuum_iceberg_tables_schedule" {
  name        = "vacuum-iceberg-tables-daily"
  description = "Daily schedule to vacuum Iceberg tables"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.schedule

  target {
    arn      =var.stepfunction_arn
    role_arn = aws_iam_role.vacuum_scheduler_role.arn

    input = jsonencode({
      DatabaseName = var.database_name
    })
  }
}
