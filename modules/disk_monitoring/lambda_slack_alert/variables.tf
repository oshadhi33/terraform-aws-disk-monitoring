variable "slack_webhook_url" {
  type        = string
  description = "Slack webhook URL to send alerts"
}

variable "sns_topic_arn" {
  type = string
}
