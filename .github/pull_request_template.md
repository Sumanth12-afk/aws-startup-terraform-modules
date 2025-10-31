# Pull Request

## 📋 Description

Brief description of changes made in this PR.

## 🎯 Type of Change

- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New module (new Terraform module)
- [ ] 🚀 Enhancement (improvement to existing module)
- [ ] 📖 Documentation (documentation changes only)
- [ ] 🔧 Refactoring (code changes that neither fix bugs nor add features)
- [ ] ✅ Tests (adding or updating tests)

## 📁 Module Checklist (if applicable)

### Required Files
- [ ] `providers.tf` with AWS provider configuration
- [ ] `backend.tf` with S3 + DynamoDB remote state
- [ ] `variables.tf` with complete definitions (including state management vars)
- [ ] `terraform.tfvars` with example values
- [ ] `main.tf` with AWS resources
- [ ] `outputs.tf` with module outputs
- [ ] `version.tf` with version constraints
- [ ] `LICENSE` (MIT)
- [ ] `README.md` with comprehensive documentation
- [ ] `examples/example.tf` with working examples

### Quality Standards
- [ ] Follows existing module patterns
- [ ] All resources properly tagged
- [ ] Security best practices implemented
- [ ] Cost optimization considered
- [ ] Documentation includes architecture diagrams
- [ ] Cost estimation provided
- [ ] Pro/Enterprise features documented

### Testing
- [ ] `terraform fmt` passes
- [ ] `terraform validate` passes
- [ ] `terraform plan` succeeds with examples
- [ ] No hardcoded sensitive values
- [ ] Variables have proper types and descriptions
- [ ] All outputs documented

## 🔗 Related Issues

Fixes #(issue number)
Related to #(issue number)

## 🧪 Testing

Describe how you tested these changes:

```bash
cd module-name
terraform init
terraform validate
terraform plan
```

## 📸 Screenshots (if applicable)

Add screenshots of CloudWatch dashboards, architecture diagrams, or terraform plan output.

## 💰 Cost Impact

Describe any cost implications of these changes:
- Estimated monthly cost: $X
- Changes to existing costs: +/- $Y

## 🔐 Security Considerations

Describe security implications:
- Encryption: [yes/no - describe]
- IAM: [least-privilege applied]
- Network: [private subnets used]

## 📝 Additional Notes

Any additional information reviewers should know:

## ✅ Reviewer Checklist

- [ ] Code follows project standards
- [ ] Documentation is clear and complete
- [ ] Security best practices followed
- [ ] Cost optimization considered
- [ ] Examples are functional
- [ ] No sensitive information exposed

---

**By submitting this PR, I confirm that my contribution is made under the terms of the MIT license.**

