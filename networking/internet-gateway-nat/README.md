# Internet Gateway and NAT Gateway Module

**Standalone module for adding internet connectivity to existing VPCs.**

This module provides Internet Gateway and NAT Gateway resources for AWS VPCs. It's useful when you need to add internet connectivity to an existing VPC or manage these resources separately from the VPC module.

---

## 📋 Features

✅ **Internet Gateway**: Public internet access for public subnets  
✅ **NAT Gateway**: Outbound internet for private subnets  
✅ **High Availability**: Optional NAT Gateway per AZ  
✅ **Cost Optimization**: Single NAT Gateway option for dev/staging  
✅ **Route Management**: Automatic route table configuration  

---

## 🚀 Usage

```hcl
module "nat_gateway" {
  source = "your-org/internet-gateway-nat/aws"
  version = "~> 1.0"

  vpc_id             = "vpc-12345678"
  name_prefix        = "production"
  
  public_subnet_ids  = ["subnet-abc123", "subnet-def456"]
  private_subnet_ids = ["subnet-111222", "subnet-333444"]

  enable_nat_gateway = true
  single_nat_gateway = false  # NAT per AZ

  tags = {
    Project = "my-startup"
  }
}
```

---

## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID | `string` | n/a | yes |
| public_subnet_ids | Public subnet IDs for NAT Gateways | `list(string)` | n/a | yes |
| private_subnet_ids | Private subnet IDs needing NAT access | `list(string)` | `[]` | no |
| enable_nat_gateway | Enable NAT Gateway | `bool` | `true` | no |
| single_nat_gateway | Use single NAT for cost savings | `bool` | `false` | no |

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| internet_gateway_id | Internet Gateway ID |
| nat_gateway_ids | NAT Gateway IDs |
| nat_gateway_public_ips | NAT Gateway public IPs |

---

## 💰 Cost Estimation

- **Internet Gateway**: $0 (free)
- **NAT Gateway**: $32.40/month per gateway + data processing ($0.045/GB)
- **Elastic IPs**: $0 when attached

**Tip**: Use `single_nat_gateway = true` for non-production to save ~$65/month per additional AZ.

---

## 📄 License

MIT License - see [LICENSE](LICENSE)

