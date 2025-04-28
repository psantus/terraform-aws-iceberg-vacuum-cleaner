output "stepfunction_arn" {
  value       = aws_sfn_state_machine.vacuum_iceberg_tables.arn
  description = "ARN of the stepfunction that will orchestrate the vacuuming"
}