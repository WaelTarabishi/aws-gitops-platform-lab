# Terraform Backend Bootstrap

Terraform cannot create its own remote backend in the same state it is about to use. Create the backend resources first, then initialize the `dev` environment with that backend.

Create these AWS resources once:

- S3 bucket for Terraform state
- DynamoDB table for state locking

Example names:

- S3 bucket: `minimized-devops-terraform-state`
- DynamoDB table: `minimized-devops-terraform-locks`

Recommended bucket settings:

- versioning enabled
- server-side encryption enabled
- block public access enabled

Recommended DynamoDB settings:

- partition key `LockID` of type `String`

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

aws dynamodb create-table \
  --table-name minimized-devops-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Then initialize the env:

```bash
cd terraform/envs/dev
terraform init -backend-config=backend.hcl
```

Do not commit real backend values if they differ per account or environment. Copy `backend.hcl.example` to `backend.hcl` locally and adjust it.
