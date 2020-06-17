provider "aws" {
}

locals {
  aws_services = {
    elasticloadbalancing = [
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroups",
    ]
    apigateway = [
      "apigateway:GET",
      "apigateway:HEAD",
      "apigateway:OPTIONS",
    ]
  }

  role_arns = {
    "devops-admin-rw-role" : "arn:aws:iam::021268868874:role/devops-admin-rw-role",
    "devops-admin-ro-role" : "arn:aws:iam::021268868874:role/devops-admin-ro-role",
    "developer-role" : "arn:aws:iam::021268868874:role/bsg-sandbox-developer-role",
    "eks-admin-role" : "arn:aws:iam::021268868874:role/bsg-sandbox-eks-admin-role",
  }

  regions = [
    "us-east-1",
    "us-west-2",
  ]

  region_service_mapping = {
    for_each = [for r in local.regions :
      {
        aws_region = r
        services   = local.aws_services
    }]
  }

  sns_topics = {
    (var.region) = local.topics,
    "us-east-1"  = var.create_route53_healthcheck ? local.topics : null
  }

  topics = {
    (var.priority) = {
      info     = []
      critical = var.priority == "P3" ? null : []
      warning  = var.priority == "P3" ? null : []
    }
  }

}

data "aws_iam_policy_document" "policy_example" {
  dynamic "statement" {
    iterator = actions
    for_each = [for s in var.aws_services : {
      service = s
      actions = lookup(local.aws_services, s)
    }]

    content {
      sid    = "Allow${title(actions.value.service)}Access"
      effect = "Allow"

      resources = [
        "*"
      ]

      actions = actions.value.actions
    }
  }
}

data "aws_iam_policy_document" "logs_kms_access_policy" {
  statement {
    sid    = "AllowCloudWatchLogsAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.us-west-2.amazonaws.com"]
    }

    resources = [
      "*",
    ]

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
  }

  statement {
    sid    = "AllowMSKAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["kafka.us-west-2.amazonaws.com"]
    }

    resources = [
      "*",
    ]

    actions = [
      "kms:*",
    ]
  }

  dynamic "statement" {
    for_each = local.role_arns
    content {
      sid    = "AllowBSG${title(statement.key)}Access"
      effect = "Allow"

      principals {
        type = "AWS"
        identifiers = [
          statement.value
        ]
      }

      resources = [
        "*",
      ]

      actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*",
      ]
    }
  }
}

data "aws_vpc" "default" {
  filter {
    name   = "is-default"
    values = ["true"]
  }
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}
