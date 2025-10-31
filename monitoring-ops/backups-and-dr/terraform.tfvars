environment      = "production"
backup_schedule  = "cron(0 2 * * ? *)"  # Daily at 2 AM UTC
retention_days   = 30

# kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/abc123"
# copy_to_vault_arn = "arn:aws:backup:us-west-2:123456789012:backup-vault:dr-vault"

tags = {
  Project = "MyApp"
  Purpose = "BackupAndDR"
}

