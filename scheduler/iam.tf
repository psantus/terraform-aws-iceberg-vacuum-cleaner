# EventBridge Scheduler Role
resource "aws_iam_role" "vacuum_scheduler_role" {
  name = "vacuum-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

# EventBridge Scheduler Policy
resource "aws_iam_policy" "vacuum_scheduler_policy" {
  name        = "vacuum-scheduler-policy"
  description = "Policy for EventBridge Scheduler to invoke Step Functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = [
          var.stepfunction_arn
        ]
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "vacuum_scheduler_attachment" {
  role       = aws_iam_role.vacuum_scheduler_role.name
  policy_arn = aws_iam_policy.vacuum_scheduler_policy.arn
}
