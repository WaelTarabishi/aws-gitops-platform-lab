# Terraform Dev Environment

This environment provisions the base AWS infrastructure for the dev cluster.

Current scope:
- VPC
- public and private subnets
- NAT gateway
- EKS cluster
- managed node group
- optional Route53 public hosted zone
- optional ACM certificate creation and DNS validation

## DNS And Certificate

For a new domain, set:

```hcl
create_route53_zone = true
route53_zone_name   = "waeltarabishi-devops.online"

create_acm_certificate  = true
certificate_domain_name = "waeltarabishi-devops.online"
certificate_subject_alternative_names = [
  "*.waeltarabishi-devops.online"
]
```

Terraform will create the Route53 hosted zone, request the ACM certificate, and create the ACM validation records.

After the first apply, read this output:

```bash
terraform output route53_name_servers
```

Put those name servers in GoDaddy as the custom nameservers for `waeltarabishi-devops.online`. DNS propagation must complete before the domain works publicly.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

The real dev values are in `terraform.tfvars`, which Terraform loads automatically from this directory.
