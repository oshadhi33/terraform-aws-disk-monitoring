# Find EC2 instances with the specified role tag
data "aws_instances" "monitored" {
  filter {
    name   = "tag:Environment"
    values = ["internal"]
  }
}

# Create SNS topic
resource "aws_sns_topic" "alerts" {
  name = var.slack_alert_topic
}

resource "aws_cloudwatch_metric_alarm" "high_usage" {
  for_each = { for id in data.aws_instances.monitored.ids : id => id }

  alarm_name          = "DiskUsageHigh-${each.key}"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.threshold_percent
  comparison_operator = "GreaterThanThreshold"
  alarm_description   = "Disk usage > ${var.threshold_percent}% on ${each.key}"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = each.key
    MountPath  = var.mount_path
    Filesystem = var.filesystem
  }
}

resource "aws_cloudwatch_metric_alarm" "low_free" {
  for_each = { for id in data.aws_instances.monitored.ids : id => id }

  alarm_name          = "DiskFreeLow-${each.key}"
  metric_name         = "disk_free"
  namespace           = "CWAgent"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.threshold_free_gb
  unit                = "Gigabytes"
  comparison_operator = "LessThanThreshold"
  alarm_description   = "Free disk space < ${var.threshold_free_gb} GB on ${each.key}"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = each.key
    MountPath  = var.mount_path
    Filesystem = var.filesystem
  }
}


module "slack_lambda" {
  source            = "./lambda_slack_alert"
  slack_webhook_url = var.slack_webhook_url
}

resource "aws_lambda_permission" "sns_allow" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.slack_lambda.lambda_arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}

resource "aws_sns_topic_subscription" "slack_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = module.slack_lambda.lambda_arn
}

