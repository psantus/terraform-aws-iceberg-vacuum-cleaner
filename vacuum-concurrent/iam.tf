data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# IAM Role for Step Functions
resource "aws_iam_role" "vacuum_iceberg_tables_role" {
  name = "vacuum-iceberg-tables-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Step Functions to access Glue and Athena
resource "aws_iam_policy" "vacuum_iceberg_tables_policy" {
  name        = "vacuum-iceberg-tables-policy"
  description = "Policy for Step Functions to access Glue and Athena for vacuuming Iceberg tables"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:GetTables",
          "glue:GetTable",
          "glue:GetDatabase",
          "glue:UpdateTable"
        ]
        Resource = [
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/*",
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults"
        ]
        Resource = [
          "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workgroup/primary"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.iceberg_table_bucket_name}",
          "arn:aws:s3:::${var.athena_queries_bucket_name}/*",
          "arn:aws:s3:::${var.athena_queries_bucket_name}/${var.athena_queries_prefix}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/states/*",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/states/*:*"
        ]
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "vacuum_iceberg_tables_attachment" {
  role       = aws_iam_role.vacuum_iceberg_tables_role.name
  policy_arn = aws_iam_policy.vacuum_iceberg_tables_policy.arn
}