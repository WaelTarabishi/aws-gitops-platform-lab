output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name."
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster API endpoint."
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "Cluster security group ID."
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID."
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "Private subnet IDs."
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "Public subnet IDs."
}

output "route53_zone_id" {
  value       = try(local.route53_zone_id, null)
  description = "Route53 public zone ID when configured."
}

output "route53_name_servers" {
  value       = try(aws_route53_zone.public[0].name_servers, null)
  description = "Route53 name servers when Terraform creates the hosted zone."
}

output "acm_certificate_arn" {
  value       = try(aws_acm_certificate_validation.gateway[0].certificate_arn, null)
  description = "Validated ACM certificate ARN when enabled."
}
