# Architecture Notes

## Why This Repo Exists

The larger reference repository demonstrates many good AWS and GitOps concepts, but it combines too many packaging and deployment patterns in one place.

This repository keeps the same direction with these simplifications:
- Kustomize for first-party applications
- Helm only for third-party controllers and platform add-ons
- Argo CD applications separated into platform and workloads
- one environment entrypoint under `clusters/dev`

## Control Planes

### Terraform
Terraform creates and updates cloud infrastructure such as:
- VPC
- subnets
- EKS
- node groups
- Route53 and ACM when enabled

### Argo CD
Argo CD watches this repository and applies:
- platform add-ons (Platform)
- application overlays

### Kustomize
Kustomize is the source of truth for our own workloads and environment composition.

## Planned Platform Add-ons

Version 1:
- namespaces

Version 2:
- AWS Load Balancer Controller
- ExternalDNS
- Gateway API and ALB routing resources
- monitoring

Version 3:
- logging stack

## Bootstrap Model

Argo CD is installed once from outside the repo.
After Argo CD is available, the root application points to `clusters/dev`.
That root application then creates the platform and application child applications.

## Current Dev Baseline

The current `dev` baseline bootstraps Gateway API CRDs from the cluster entrypoint, installs the AWS Load Balancer Controller in the platform layer, and exposes the sample application through an `HTTPRoute`.
The first routing step is public HTTP so the gateway can be stood up before wiring a certificate ARN into the Git-managed manifests for HTTPS.
