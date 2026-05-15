data "archive_file" "slack_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/handler.py"
  output_path = "${path.module}/slack_alert_lambda.zip"
}

resource "aws_iam_role" "slack_lambda" {
  name = "disk-monitoring-slack-alert-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.slack_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "slack_alert" {
  function_name = "disk-monitoring-slack-alert"
  role          = aws_iam_role.slack_lambda.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.10"

  filename         = data.archive_file.slack_lambda_zip.output_path
  source_code_hash = data.archive_file.slack_lambda_zip.output_base64sha256

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }

  timeout = 10
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_alert.arn
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}
