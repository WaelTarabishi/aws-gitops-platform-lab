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
