# Terraform Backend Bootstrap

Terraform cannot create its own remote backend in the same state it is about to use. Create the backend resources first, then initialize the `dev` environment with that backend.

## Locking Approach

This repo originally considered the older `dynamodb_table` locking pattern for the `s3` backend.

That is no longer the recommended approach here.

The current and recommended setup is:

- S3 bucket for Terraform state
- `use_lockfile = true` for backend locking

Why this changed:

- Terraform now warns that `dynamodb_table` in the `s3` backend is deprecated
- S3 lockfile locking is the newer backend approach
- it removes the extra DynamoDB table dependency for this project

Create these AWS resources once:

- S3 bucket for Terraform state

Example names:

- S3 bucket: `minimized-devops-terraform-state`

Recommended bucket settings:

- versioning enabled
- server-side encryption enabled
- block public access enabled

There is no DynamoDB table in the current backend design.
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
