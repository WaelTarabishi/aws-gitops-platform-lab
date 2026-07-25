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
aws s3api create-bucket \
  --bucket minimized-devops-terraform-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket minimized-devops-terraform-state \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
  --bucket minimized-devops-terraform-state \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

The real dev values are in `terraform.tfvars`, which Terraform loads automatically from this directory.

## Remote State

This environment uses an `s3` backend with S3 lockfile locking.

Why:
- S3 stores shared Terraform state remotely
- the S3 lockfile prevents two applies from modifying the same state at the same time

Files:
- `backend.tf` declares the backend type
- `backend.hcl.example` shows the backend settings to pass into `terraform init`

Before the first `terraform init`, create the backend resources described in [`terraform/bootstrap/README.md`](C:/Users/waelt/Desktop/minimized-devops-project/terraform/bootstrap/README.md:1).
