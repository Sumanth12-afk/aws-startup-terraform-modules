# Contributing to AWS Startup Terraform Modules

Thank you for your interest in contributing! This project aims to provide production-ready Terraform modules for AWS startups.

## 🎯 Contribution Guidelines

### Types of Contributions

We welcome:
- 🐛 **Bug fixes**
- ✨ **New modules**
- 📖 **Documentation improvements**
- 🎨 **Code quality improvements**
- 💡 **Feature enhancements**

### Before You Start

1. Check existing [Issues](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/issues) and [Pull Requests](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/pulls)
2. For major changes, open an issue first to discuss
3. Review the [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) for module standards

## 📝 Module Contribution Checklist

When contributing a new module, ensure it includes:

### Required Files
- [ ] `providers.tf` - AWS provider configuration
- [ ] `backend.tf` - S3 + DynamoDB remote state
- [ ] `variables.tf` - Complete variable definitions (including state management vars)
- [ ] `terraform.tfvars` - Example values
- [ ] `main.tf` - AWS resources
- [ ] `outputs.tf` - Module outputs
- [ ] `version.tf` - Terraform/provider versions
- [ ] `LICENSE` - MIT License
- [ ] `README.md` - Comprehensive documentation
- [ ] `examples/example.tf` - Working examples

### Quality Standards

- [ ] Code follows existing module patterns
- [ ] All resources have proper tags
- [ ] Security best practices implemented:
  - [ ] Encryption at rest and in transit
  - [ ] Least-privilege IAM roles
  - [ ] Private subnets for sensitive resources
  - [ ] Security groups with minimal access
- [ ] Cost optimization considered:
  - [ ] Right-sized defaults
  - [ ] Optional features for dev/staging
  - [ ] Auto-scaling where appropriate
- [ ] Documentation includes:
  - [ ] Feature list
  - [ ] Architecture diagram
  - [ ] Usage examples (basic + advanced)
  - [ ] Complete inputs/outputs tables
  - [ ] Cost estimation
  - [ ] Security best practices
  - [ ] Pro/Enterprise features section

### Testing Requirements

- [ ] `terraform fmt` passes
- [ ] `terraform validate` passes
- [ ] `terraform plan` succeeds with example configuration
- [ ] No hardcoded values
- [ ] Variables have proper types and descriptions
- [ ] Outputs are documented

## 🔄 Development Workflow

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
git clone https://github.com/YOUR_USERNAME/aws-startup-terraform-modules.git
cd aws-startup-terraform-modules
git remote add upstream https://github.com/Sumanth12-afk/aws-startup-terraform-modules.git
```

### 2. Create a Branch

```bash
git checkout -b feature/your-module-name
# or
git checkout -b fix/issue-description
```

### 3. Make Your Changes

Follow the patterns in existing modules. Use [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) as reference.

### 4. Test Your Changes

```bash
cd your-module-directory

# Format code
terraform fmt -recursive

# Validate
terraform init
terraform validate

# Test plan
terraform plan
```

### 5. Commit Your Changes

```bash
git add .
git commit -m "feat: add your-module-name module

- Complete description of what was added
- Any important implementation details
- Reference to related issues"
```

**Commit Message Format:**
- `feat:` New feature or module
- `fix:` Bug fix
- `docs:` Documentation changes
- `chore:` Maintenance tasks
- `refactor:` Code refactoring
- `test:` Test additions/changes

### 6. Push and Create Pull Request

```bash
git push origin feature/your-module-name
```

Then create a Pull Request on GitHub with:
- Clear title and description
- Link to related issues
- Screenshots/examples if relevant
- Checklist of completed items

## 📋 Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New module
- [ ] Documentation update
- [ ] Code refactoring

## Module Checklist (if applicable)
- [ ] All required files included
- [ ] Documentation complete
- [ ] Examples provided
- [ ] Tests passing
- [ ] Security best practices followed

## Testing
How was this tested?

## Related Issues
Fixes #(issue number)
```

## 🎨 Code Style

### Terraform Conventions

1. **Naming**:
   - Use snake_case for resource names: `aws_vpc.main`
   - Use descriptive names: `private_subnet_ids` not `priv_sn`

2. **Organization**:
   - Group related resources together
   - Use comments to separate sections
   - Order: data sources → locals → resources

3. **Variables**:
   - Always include descriptions
   - Always specify types
   - Provide sensible defaults where appropriate
   - Use validation blocks for constraints

4. **Formatting**:
   - Run `terraform fmt` before committing
   - Use consistent indentation (2 spaces)
   - Align equals signs in blocks

### Documentation Style

1. **README Structure**:
   - Follow existing module README templates
   - Include ASCII architecture diagrams
   - Provide cost estimates
   - Document security considerations

2. **Code Comments**:
   - Comment complex logic
   - Explain "why" not "what"
   - Keep comments up-to-date

## 🐛 Reporting Bugs

### Before Reporting

1. Check if the bug is already reported
2. Test with latest version
3. Try to reproduce with minimal example

### Bug Report Template

```markdown
**Description**
Clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Run command '...'
2. See error '...'

**Expected Behavior**
What should happen

**Environment**
- Module: [e.g., vpc-networking]
- Terraform version: [e.g., 1.5.0]
- AWS provider version: [e.g., 5.0]
- OS: [e.g., Ubuntu 22.04]

**Additional Context**
Any other relevant information
```

## 💡 Suggesting Enhancements

### Feature Request Template

```markdown
**Problem**
What problem does this solve?

**Proposed Solution**
How should it work?

**Alternatives Considered**
Other approaches you've thought about

**Additional Context**
Examples, mockups, related issues
```

## 📖 Documentation Contributions

Documentation improvements are always welcome:

- Fix typos or clarify existing docs
- Add more examples
- Improve architecture diagrams
- Translate documentation
- Add troubleshooting guides

## 🏆 Recognition

Contributors will be:
- Listed in the project README
- Mentioned in release notes
- Given credit in module documentation

## ❓ Questions?

- Open a [Discussion](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/discussions)
- Check existing [Issues](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/issues)
- Review [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to AWS Startup Terraform Modules!** 🚀

Together, we're making AWS infrastructure deployment easier for startups worldwide.

