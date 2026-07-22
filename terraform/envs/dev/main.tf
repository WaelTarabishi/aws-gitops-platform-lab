locals {
  name                = "${var.project_name}-${var.environment}"
  route53_enabled     = var.route53_zone_name != ""
  certificate_enabled = var.create_acm_certificate && var.certificate_domain_name != "" && local.route53_enabled

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

data "aws_route53_zone" "public" {
  count        = local.route53_enabled && !var.create_route53_zone ? 1 : 0
  name         = var.route53_zone_name
  private_zone = false
}

resource "aws_route53_zone" "public" {
  count = local.route53_enabled && var.create_route53_zone ? 1 : 0

  name = var.route53_zone_name
  tags = local.common_tags
}

locals {
  route53_zone_id = var.create_route53_zone ? try(aws_route53_zone.public[0].zone_id, null) : try(data.aws_route53_zone.public[0].zone_id, null)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs              = var.availability_zones
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${local.name}-eks"
  kubernetes_version = var.cluster_version

  enable_irsa                              = true
  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size
    }
  }

  tags = local.common_tags
}

resource "aws_acm_certificate" "gateway" {
  count                     = local.certificate_enabled ? 1 : 0
  domain_name               = var.certificate_domain_name
  subject_alternative_names = var.certificate_subject_alternative_names
  validation_method         = "DNS"
  tags                      = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = local.certificate_enabled ? {
    for dvo in aws_acm_certificate.gateway[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  zone_id = local.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "gateway" {
  count = local.certificate_enabled ? 1 : 0

  certificate_arn         = aws_acm_certificate.gateway[0].arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}
