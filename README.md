# Minimized DevOps Project

This repository keeps the AWS and GitOps direction of the larger reference project, but reduces complexity by using one clear delivery model.

Core rules:
- Terraform owns AWS infrastructure.
- Argo CD owns Git synchronization.
- Kustomize owns first-party application manifests.
- Helm is allowed only for third-party platform tools when it reduces maintenance.
- There is one main cluster entrypoint per environment.

## Target Architecture

Phase 1:
- VPC
- EKS
- Managed node group
- Argo CD bootstrap
- One Kustomize-managed application

Phase 2:
- AWS Load Balancer Controller and Gateway API path
- ACM certificate
- Route53
- ExternalDNS

Phase 3:
- Argo CD Image Updater
- Monitoring
- Logging

## Repository Layout

```text
terraform/             AWS infrastructure
argocd/                bootstrap and Argo CD applications
platform/              platform add-ons synced by Argo CD
apps/                  first-party workloads managed with Kustomize
clusters/              environment entrypoints for Argo CD root apps
docs/                  design notes and implementation decisions
```

## Delivery Model

The repo intentionally avoids mixing these models for first-party apps:
- local Helm charts
- duplicate raw manifests
- generated release bundles

Instead, the main flow is:

```text
Git -> Argo CD -> Kustomize -> Kubernetes
```

For third-party platform tooling, Argo CD may deploy upstream Helm charts directly.

## First Environment

The initial environment is `dev`.
It is the only environment that should be implemented until the full flow is working.

## Bootstrap Flow

Use this order for the `dev` environment:

1. Provision AWS infrastructure with Terraform.
2. Update local kubeconfig for the EKS cluster.
3. Install Argo CD into the cluster.
4. Apply the root Argo CD application from [`argocd/root-dev.yaml`](C:/Users/waelt/Desktop/minimized-devops-project/argocd/root-dev.yaml:1).
5. Let Argo CD sync the platform and application child apps from [`clusters/dev/kustomization.yaml`](C:/Users/waelt/Desktop/minimized-devops-project/clusters/dev/kustomization.yaml:1).

Example commands:

```bash
cd terraform/envs/dev
terraform init
terraform apply

aws eks update-kubeconfig --region us-east-1 --name minimized-devops-dev-eks

kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -f argocd/root-dev.yaml
```

`Kustomize` is not a separate manual deployment step in the normal flow. Argo CD renders the Kustomize sources from Git and applies them to the cluster.

## Publishing Boutique Lite Images

The `boutique-lite` workload uses 10 service images. For EKS, those images must be pushed to a registry that the cluster can pull from. A simple default for this repo is GitHub Container Registry under the `WaelTarabishi` account.

Log in to GHCR:

```bash
echo <GHCR_TOKEN> | docker login ghcr.io -u WaelTarabishi --password-stdin
```

Build and push all boutique-lite images:

```powershell
$images = @(
  "adservice",
  "cartservice",
  "checkoutservice",
  "currencyservice",
  "emailservice",
  "frontend",
  "paymentservice",
  "productcatalogservice",
  "recommendationservice",
  "shippingservice"
)

$user = "WaelTarabishi"
$tag = "dev"

foreach ($image in $images) {
  $target = "ghcr.io/$user/boutique-lite-$image:$tag"
  docker build -t $target "./src/$image"
  docker push $target
}
```

That publishes images such as:

```text
ghcr.io/WaelTarabishi/boutique-lite-frontend:dev
ghcr.io/WaelTarabishi/boutique-lite-adservice:dev
```

After pushing, update the image references in [`apps/boutique-lite/base`](C:/Users/waelt/Desktop/minimized-devops-project/apps/boutique-lite/base:1) to use the GHCR paths and commit the manifest changes so Argo CD can redeploy the workloads.
