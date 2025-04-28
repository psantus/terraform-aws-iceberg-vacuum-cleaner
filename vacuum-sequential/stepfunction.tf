# Step Functions State Machine
resource "aws_sfn_state_machine" "vacuum_iceberg_tables" {
  name     = var.stepfunction_name
  role_arn = aws_iam_role.vacuum_iceberg_tables_role.arn

  definition = jsonencode({
    Comment = "A workflow to vacuum Iceberg tables in a Glue database"
    StartAt = "GetGlueTables"
    States = {
      GetGlueTables = {
        Type     = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:getTables",
        Parameters = {
          "DatabaseName.$" = "$.DatabaseName"
        },
        ResultPath = "$.GlueTablesResult",
        Next       = "FilterIcebergTables"
      },
      FilterIcebergTables = {
        Type = "Pass",
        Parameters = {
          "TableNames.$" : "$.GlueTablesResult.TableList[?(@.Parameters.table_type == 'ICEBERG')].Name",
          "DatabaseName.$" : "$.DatabaseName"
        },
        Next = "CheckIfTablesExist"
      },
      CheckIfTablesExist = {
        Type = "Choice",
        Choices = [
          {
            Variable  = "$.TableNames[0]",
            IsPresent = true,
            Next      = "ProcessFirstTable"
          }
        ],
        Default = "NoTablesFound"
      },
      NoTablesFound = {
        Type = "Pass",
        Result = {
          Status  = "Success",
          Message = "No Iceberg tables found to vacuum"
        },
        End = true
      },
      ProcessFirstTable = {
        Type = "Pass",
        Parameters = {
          "CurrentTable.$" : "$.TableNames[0]",
          "RemainingTables.$" : "$.TableNames[1:]",
          "DatabaseName.$" : "$.DatabaseName",
          "ProcessedTables" : []
        },
        Next = "VacuumCurrentTable"
      },
      VacuumCurrentTable = {
        Type     = "Task",
        Resource = "arn:aws:states:::athena:startQueryExecution.sync",
        Parameters = {
          "QueryString.$" = "States.Format('VACUUM {}.{};', $.DatabaseName, $.CurrentTable)",
          "WorkGroup"     = "primary",
          "ResultConfiguration" = {
            "OutputLocation" = "s3://${var.athena_queries_bucket_name}/${var.athena_queries_prefix}/"
          }
        },
        ResultPath = "$.VacuumResult",
        Retry = [
          {
            ErrorEquals     = ["Athena.TooManyRequestsException"],
            IntervalSeconds = 5,
            MaxAttempts     = 10,
            BackoffRate     = 2
          },
          {
            ErrorEquals     = ["States.TaskFailed"],
            IntervalSeconds = 1,
            MaxAttempts     = 10
          }
        ],
        Catch = [
          {
            ErrorEquals = ["States.ALL"],
            ResultPath  = "$.Error",
            Next        = "CheckForMoreTables"
          }
        ],
        Next = "RecordSuccess"
      },
      RecordSuccess = {
        Type = "Pass",
        Parameters = {
          "RemainingTables.$" : "$.RemainingTables",
          "DatabaseName.$" : "$.DatabaseName",
          "CurrentTable.$" : "$.CurrentTable",
          "ProcessedTables.$" : "States.Array($.ProcessedTables, $.CurrentTable)",
          "LastStatus" : "Success"
        },
        Next = "CheckForMoreTables"
      },
      CheckForMoreTables = {
        Type = "Choice",
        Choices = [
          {
            Variable  = "$.RemainingTables[0]",
            IsPresent = true,
            Next      = "ProcessNextTable"
          }
        ],
        Default = "WorkflowComplete"
      },
      ProcessNextTable = {
        Type = "Pass",
        Parameters = {
          "RemainingTables.$" : "$.RemainingTables[1:]",
          "CurrentTable.$" : "$.RemainingTables[0]",
          "DatabaseName.$" : "$.DatabaseName",
          "ProcessedTables.$" : "$.ProcessedTables"
        },
        Next = "VacuumCurrentTable"
      },
      WorkflowComplete = {
        Type = "Pass",
        Result = {
          Status  = "Success",
          Message = "All vacuum operations completed"
        },
        End = true
      }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.vacuum_iceberg_tables_logs.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "vacuum_iceberg_tables_logs" {
  name              = "/aws/states/${var.stepfunction_name}"
  retention_in_days = 30
}