module "parameters" {
  source = "../"

  environment = "production"

  parameters = {
    "app/config" = {
      description = "App configuration"
      type        = "String"
      value       = "config-value"
      tier        = "Standard"
    }
  }

  kms_key_id = module.kms.key_id
  tags       = { Project = "MyApp" }
}

