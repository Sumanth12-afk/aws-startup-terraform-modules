module "backups" {
  source = "../"

  environment     = "production"
  backup_schedule = "cron(0 2 * * ? *)"
  retention_days  = 30

  kms_key_arn = module.kms.key_arn

  tags = { Project = "MyApp" }
}

