variable "role_tag" {
  description = "Tag value for EC2 instances to monitor"
  type        = string
}

variable "slack_alert_topic" {
  description = "Name of the SNS topic to send alerts to"
  type        = string
}

variable "mount_path" {
  description = "Mount path to monitor (e.g. /)"
  type        = string
}

variable "filesystem" {
  description = "Filesystem device name (e.g. /dev/nvme0n1p1)"
  type        = string
}

variable "threshold_percent" {
  description = "Disk usage percentage threshold"
  type        = number
  default     = 80
}

variable "threshold_free_gb" {
  description = "Minimum free space threshold in GB"
  type        = number
  default     = 5
}

variable "slack_webhook_url" {
  description = "Slack webhook URL to send alerts"
  type        = string
}
