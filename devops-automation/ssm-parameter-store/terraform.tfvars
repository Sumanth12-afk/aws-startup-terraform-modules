environment = "production"

parameters = {
  "app/database/host" = {
    description = "Database host"
    type        = "String"
    value       = "db.example.com"
    tier        = "Standard"
  }
  "app/api/key" = {
    description = "API key"
    type        = "SecureString"
    value       = "secret-key-value"
    tier        = "Standard"
  }
}

tags = {
  Project = "MyApp"
}

