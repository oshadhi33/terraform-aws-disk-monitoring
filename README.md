# Terraform AWS Disk Monitoring Module

A Terraform module for monitoring EC2 instance disk usage with CloudWatch alarms and Slack alerts.

## Features

- Monitors disk usage percentage and free space on EC2 instances
- Sends alerts to Slack via SNS and Lambda
- Configurable thresholds for disk usage and free space
- Automatically discovers instances by environment tag

## Usage

```hcl
module "disk_monitoring" {
  source = "./modules/disk_monitoring"

  role_tag           = "internal"
  slack_alert_topic  = "disk-monitoring-alerts"
  mount_path         = "/"
  filesystem         = "/dev/nvme0n1p1"
  threshold_percent  = 80
  threshold_free_gb  = 5
  slack_webhook_url  = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
}
```

## Requirements
- Terraform >= 1.0
- AWS provider >= 4.0
- EC2 instances with CloudWatch Agent installed

## Inputs
| Variable            | Description                                    | Type     | Default |
| ------------------- | ---------------------------------------------- | -------- | ------- |
| `role_tag`          | Tag value for EC2 instances to monitor         | `string` | `-`     |
| `slack_alert_topic` | Name of the SNS topic to send alerts to        | `string` | `-`     |
| `mount_path`        | Mount path to monitor (e.g. `/`)               | `string` | `-`     |
| `filesystem`        | Filesystem device name (e.g. `/dev/nvme0n1p1`) | `string` | `-`     |
| `threshold_percent` | Disk usage percentage threshold                | `number` | `80`    |
| `threshold_free_gb` | Minimum free space threshold in GB             | `number` | `5`     |
| `slack_webhook_url` | Slack webhook URL to send alerts               | `string` | `-`     |

## Outputs
| Output          | Description                     |
| --------------- | ------------------------------- |
| `sns_topic_arn` | ARN of the SNS topic for alerts |
