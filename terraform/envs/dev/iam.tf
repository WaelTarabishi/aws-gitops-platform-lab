data "aws_partition" "current" {}

data "aws_iam_policy_document" "eks_pod_identity_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
  }
}

data "aws_iam_policy_document" "external_dns" {
  count = local.route53_enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResources",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:route53:::hostedzone/${local.route53_zone_id}",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = "${local.name}-aws-load-balancer-controller"
  assume_role_policy = data.aws_iam_policy_document.eks_pod_identity_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
}

resource "aws_eks_pod_identity_association" "aws_load_balancer_controller" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws_load_balancer_controller.arn
  tags            = local.common_tags
}

resource "aws_iam_role" "external_dns" {
  count = local.route53_enabled ? 1 : 0

  name               = "${local.name}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.eks_pod_identity_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "external_dns" {
  count = local.route53_enabled ? 1 : 0

  name   = "${local.name}-external-dns"
  policy = data.aws_iam_policy_document.external_dns[0].json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  count = local.route53_enabled ? 1 : 0

  role       = aws_iam_role.external_dns[0].name
  policy_arn = aws_iam_policy.external_dns[0].arn
}

resource "aws_eks_pod_identity_association" "external_dns" {
  count = local.route53_enabled ? 1 : 0

  cluster_name    = module.eks.cluster_name
  namespace       = "external-dns"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external_dns[0].arn
  tags            = local.common_tags
}
