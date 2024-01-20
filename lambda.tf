data "archive_file" "submission_main" {
  type        = "zip"
  source_file = "lambda/submission/submission.js"
  output_path = "/tmp/submission_main.zip"
}

data "archive_file" "submission_lib" {
  type        = "zip"
  source_dir  = "lambda/submission/"
  excludes    = ["submission.js"]
  output_path = "/tmp/submission_lib.zip"
}

resource "aws_lambda_function" "submission" {
  filename      = "/tmp/submission_main.zip"
  function_name = "Submission"
  role          = aws_iam_role.lambda.arn
  handler       = "submission.handler"
  timeout       = 60

  source_code_hash = data.archive_file.submission_main.output_base64sha256

  runtime = "nodejs18.x"
  layers = [
    aws_lambda_layer_version.submission_lib.arn
  ]

  environment {
    variables = {
      REGION  = "ca-central-1"
      SQS_URL = "1234"
    }
  }

  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_lambda_layer_version" "submission_lib" {
  filename            = "/tmp/submission_lib.zip"
  layer_name          = "submission_node_packages"
  source_code_hash    = data.archive_file.submission_lib.output_base64sha256
  compatible_runtimes = ["nodejs18.x"]
}

resource "aws_cloudwatch_log_group" "submission" {
  name              = "/aws/lambda/${aws_lambda_function.submission.function_name}"
  retention_in_days = 90
}

#
# IAM
#
resource "aws_iam_role" "lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_policy_attachment" "lambda_logging" {
  name       = "lambda_logging"
  roles      = [aws_iam_role.lambda.name]
  policy_arn = aws_iam_policy.lambda_logging.arn
}
