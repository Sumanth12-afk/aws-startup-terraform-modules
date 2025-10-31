module "monitoring" {
  source = "../"

  environment      = "production"
  email_endpoints  = ["ops@example.com"]
  
  enable_ec2_alarms = true
  ec2_instance_ids  = module.ec2.instance_ids
  
  enable_rds_alarms = true
  rds_instance_ids  = [module.rds.instance_id]
  
  create_dashboard = true
  
  tags = { Project = "MyApp" }
}

