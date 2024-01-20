data "archive_file" "submission_code" {
  type        = "zip"
  source_dir  = "./code/submission/dist"
  output_path = "/tmp/submission_code.zip"
}

resource "aws_s3_object" "submission_code" {
  bucket      = aws_s3_bucket.lambda_code.id
  key         = "submission_code"
  source      = data.archive_file.submission_code.output_path
  source_hash = data.archive_file.submission_code.output_base64sha256
}

resource "aws_lambda_function" "submission" {
  s3_bucket         = aws_s3_object.submission_code.bucket
  s3_key            = aws_s3_object.submission_code.key
  s3_object_version = aws_s3_object.submission_code.version_id
  function_name     = "Submission"
  role              = aws_iam_role.lambda.arn
  handler           = "submission.handler"
  timeout           = 60

  source_code_hash = data.archive_file.submission_code.output_base64sha256

  runtime = "nodejs18.x"

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
