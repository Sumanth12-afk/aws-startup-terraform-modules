module "budget" {
  source = "../"

  environment          = "production"
  monthly_budget_limit = "1000"
  email_addresses      = ["finance@example.com"]
  
  enable_anomaly_detection = true
  anomaly_threshold        = 100
  
  tags = { Project = "MyApp" }
}

