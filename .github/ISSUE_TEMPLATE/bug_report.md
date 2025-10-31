---
name: Bug Report
about: Report a bug or issue with a module
title: '[BUG] '
labels: bug
assignees: ''
---

## 🐛 Bug Description

A clear and concise description of the bug.

## 📍 Module Affected

- Module: [e.g., `networking/vpc-networking`]
- Version: [e.g., 1.0.0]

## 🔄 Steps to Reproduce

1. Configure module with '...'
2. Run `terraform apply`
3. See error '...'

## ✅ Expected Behavior

What should happen instead?

## ❌ Actual Behavior

What actually happened?

## 📋 Configuration

```hcl
# Paste your module configuration here (remove sensitive data)
module "example" {
  source = "..."
  
  # Configuration...
}
```

## 📊 Terraform Output

```
# Paste relevant terraform plan/apply output or error messages
```

## 🖥️ Environment

- **Terraform Version**: [e.g., 1.5.0]
- **AWS Provider Version**: [e.g., 5.0.0]
- **OS**: [e.g., Ubuntu 22.04, macOS 13, Windows 11]
- **AWS Region**: [e.g., us-east-1]

## 📸 Screenshots

If applicable, add screenshots to help explain the problem.

## 📝 Additional Context

Add any other context about the problem here.

## ✅ Checklist

- [ ] I've checked existing issues for duplicates
- [ ] I've tested with the latest module version
- [ ] I've run `terraform fmt` and `terraform validate`
- [ ] I've removed sensitive information from outputs

