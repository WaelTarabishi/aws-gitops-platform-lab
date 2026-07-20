variable "project_name" {
  type        = string
  description = "Project name used for tags and resource naming."
  default     = "minimized-devops"
}

variable "environment" {
  type        = string
  description = "Deployment environment name."
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region for the dev environment."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones used for the VPC and EKS node placement."
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet CIDRs."
  default     = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDRs."
  default     = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]
}

variable "cluster_version" {
  type        = string
  description = "EKS Kubernetes version."
  default     = "1.34"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Managed node group instance types."
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  type        = number
  description = "Desired size of the dev node group."
  default     = 2
}

variable "node_min_size" {
  type        = number
  description = "Minimum size of the dev node group."
  default     = 2
}

variable "node_max_size" {
  type        = number
  description = "Maximum size of the dev node group."
  default     = 4
}

variable "route53_zone_name" {
  type        = string
  description = "Route53 public zone name, for example example.com. Leave empty to skip DNS resources."
  default     = ""
}

variable "create_route53_zone" {
  type        = bool
  description = "Whether Terraform should create the public Route53 hosted zone instead of looking up an existing one."
  default     = false
}

variable "create_acm_certificate" {
  type        = bool
  description = "Whether to request and validate an ACM certificate."
  default     = false
}

variable "certificate_domain_name" {
  type        = string
  description = "Primary domain name for ACM certificate, typically the apex domain such as example.com."
  default     = ""
}

variable "certificate_subject_alternative_names" {
  type        = list(string)
  description = "Optional ACM subject alternative names, for example [\"*.example.com\"]."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to resources."
  default     = {}
}
