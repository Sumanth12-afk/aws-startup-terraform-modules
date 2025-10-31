environment = "production"
aws_region  = "us-east-1"

alarm_topic_name = "monitoring-alarms"
email_endpoints  = ["devops@example.com"]

enable_ec2_alarms = true
ec2_instance_ids  = ["i-1234567890abcdef0"]
ec2_cpu_threshold = 80

enable_rds_alarms = true
rds_instance_ids  = ["mydb-prod"]
rds_cpu_threshold = 75

create_dashboard = true

tags = {
  Project = "MyApp"
}

