# Terraform Backend Bootstrap

Terraform cannot create its own remote backend in the same state it is about to use. Create the backend resources first, then initialize the `dev` environment with that backend.

Create these AWS resources once:

- S3 bucket for Terraform state

Example names:

- S3 bucket: `minimized-devops-terraform-state`

Recommended bucket settings:

- versioning enabled
- server-side encryption enabled
- block public access enabled

Reco
Example AWS CLI commands:

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

```

Then initialize the env:

```bash
cd terraform/envs/dev
terraform init -backend-config=backend.hcl
```

Do not commit real backend values if they differ per account or environment. Copy `backend.hcl.example` to `backend.hcl` locally and adjust it.
