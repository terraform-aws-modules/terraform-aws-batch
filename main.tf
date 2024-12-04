data "aws_partition" "current" {
  count = var.create ? 1 : 0
}

locals {
  partition  = try(data.aws_partition.current[0].partition, "")
  dns_suffix = try(data.aws_partition.current[0].dns_suffix, "")
}

################################################################################
# Compute Environment(s)
################################################################################

resource "aws_batch_compute_environment" "this" {
  for_each = { for k, v in var.compute_environments : k => v if var.create }

  compute_environment_name        = lookup(each.value, "name", null)
  compute_environment_name_prefix = try(each.value.name_prefix, null) != null ? "${each.value.name_prefix}-" : null

  service_role = var.create_service_iam_role ? aws_iam_role.service[0].arn : each.value.service_role
  type         = lookup(each.value, "type", "MANAGED")

  dynamic "compute_resources" {
    for_each = can(each.value.compute_resources.subnets) ? [each.value.compute_resources] : []
    content {
      type                = compute_resources.value.type
      allocation_strategy = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : try(compute_resources.value.allocation_strategy, null)
      bid_percentage      = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : try(compute_resources.value.bid_percentage, null)

      min_vcpus     = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : try(compute_resources.value.min_vcpus, null)
      max_vcpus     = compute_resources.value.max_vcpus
      desired_vcpus = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : try(compute_resources.value.desired_vcpus, null)
      instance_type = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? [] : try(compute_resources.value.instance_types, [])
      ec2_key_pair  = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : try(compute_resources.value.ec2_key_pair, null)

      instance_role       = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : try(compute_resources.value.instance_role, aws_iam_instance_profile.instance[0].arn, null)
      spot_iam_fleet_role = compute_resources.value.type == "SPOT" ? try(aws_iam_role.spot_fleet[0].arn, compute_resources.value.spot_fleet_role, null) : null
      security_group_ids  = compute_resources.value.security_group_ids
      subnets             = compute_resources.value.subnets

      # We do not merge with default `var.tags` here because tag changes for compute environment replacement
      tags = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : lookup(compute_resources.value, "tags", {})

      dynamic "ec2_configuration" {
        for_each = !contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) && try(compute_resources.value.ec2_configuration, null) != null ? [compute_resources.value.ec2_configuration] : []
        content {
          image_id_override = lookup(ec2_configuration.value, "image_id_override", null)
          image_type        = lookup(ec2_configuration.value, "image_type", null)
        }
      }

      dynamic "launch_template" {
        for_each = !contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) && try(compute_resources.value.launch_template, null) != null ? [compute_resources.value.launch_template] : []
        content {
          launch_template_id   = lookup(launch_template.value, "id", lookup(launch_template.value, "launch_template_id", null))
          launch_template_name = lookup(launch_template.value, "name", lookup(launch_template.value, "launch_template_name", null))
          version              = lookup(launch_template.value, "version", null)
        }
      }
    }
  }

  dynamic "eks_configuration" {
    for_each = try([each.value.eks_configuration], [])

    content {
      eks_cluster_arn      = eks_configuration.value.eks_cluster_arn
      kubernetes_namespace = eks_configuration.value.kubernetes_namespace
    }
  }

  # Prevent a race condition during environment deletion, otherwise the policy may be destroyed
  # too soon and the compute environment will then get stuck in the `DELETING` state
  depends_on = [aws_iam_role_policy_attachment.service]

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    { terraform-aws-modules = "batch" },
    var.tags,
    try(each.value.tags, {})
  )
}

################################################################################
# Compute Environment - Instance Role
################################################################################

locals {
  create_instance_iam_role = var.create && var.create_instance_iam_role
}

data "aws_iam_policy_document" "instance" {
  count = local.create_instance_iam_role ? 1 : 0

  statement {
    sid     = "ECSAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${local.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "instance" {
  count = local.create_instance_iam_role ? 1 : 0

  name        = var.instance_iam_role_use_name_prefix ? null : var.instance_iam_role_name
  name_prefix = var.instance_iam_role_use_name_prefix ? "${var.instance_iam_role_name}-" : null
  path        = var.instance_iam_role_path
  description = var.instance_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.instance[0].json
  permissions_boundary  = var.instance_iam_role_permissions_boundary
  force_detach_policies = true

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    var.instance_iam_role_tags,
  )
}

resource "aws_iam_role_policy_attachment" "instance" {
  for_each = { for k, v in merge(
    {
      AmazonEC2ContainerServiceforEC2Role = "arn:${local.partition}:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    },
  var.instance_iam_role_additional_policies) : k => v if local.create_instance_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.instance[0].name
}

resource "aws_iam_instance_profile" "instance" {
  count = local.create_instance_iam_role ? 1 : 0

  name        = var.instance_iam_role_use_name_prefix ? null : var.instance_iam_role_name
  name_prefix = var.instance_iam_role_use_name_prefix ? "${var.instance_iam_role_name}-" : null
  path        = var.instance_iam_role_path
  role        = aws_iam_role.instance[0].name

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    var.instance_iam_role_tags,
  )
}

################################################################################
# Compute Environment - Service Role
################################################################################

locals {
  create_service_iam_role = var.create && var.create_service_iam_role
}

data "aws_iam_policy_document" "service" {
  count = local.create_service_iam_role ? 1 : 0

  statement {
    sid     = "ECSAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["batch.${local.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "service" {
  count = local.create_service_iam_role ? 1 : 0

  name        = var.service_iam_role_use_name_prefix ? null : var.service_iam_role_name
  name_prefix = var.service_iam_role_use_name_prefix ? "${var.service_iam_role_name}-" : null
  path        = var.service_iam_role_path
  description = var.service_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.service[0].json
  permissions_boundary  = var.service_iam_role_permissions_boundary
  force_detach_policies = true

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    var.service_iam_role_tags,
  )
}

resource "aws_iam_role_policy_attachment" "service" {
  for_each = { for k, v in merge(
    {
      AWSBatchServiceRole = "arn:${local.partition}:iam::aws:policy/service-role/AWSBatchServiceRole"
    },
  var.service_iam_role_additional_policies) : k => v if local.create_service_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.service[0].name
}

################################################################################
# Compute Environment - Spot Fleet Role
################################################################################

locals {
  create_spot_fleet_iam_role = var.create && var.create_spot_fleet_iam_role
}

data "aws_iam_policy_document" "spot_fleet" {
  count = local.create_spot_fleet_iam_role ? 1 : 0

  statement {
    sid     = "ECSAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["spotfleet.${local.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "spot_fleet" {
  count = local.create_spot_fleet_iam_role ? 1 : 0

  name        = var.spot_fleet_iam_role_use_name_prefix ? null : var.spot_fleet_iam_role_name
  name_prefix = var.spot_fleet_iam_role_use_name_prefix ? "${var.spot_fleet_iam_role_name}-" : null
  path        = var.spot_fleet_iam_role_path
  description = var.spot_fleet_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.spot_fleet[0].json
  permissions_boundary  = var.spot_fleet_iam_role_permissions_boundary
  force_detach_policies = true

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    var.spot_fleet_iam_role_tags,
  )
}

resource "aws_iam_role_policy_attachment" "spot_fleet" {
  for_each = { for k, v in merge(
    {
      AmazonEC2SpotFleetTaggingRole = "arn:${local.partition}:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
    },
  var.spot_fleet_iam_role_additional_policies) : k => v if local.create_spot_fleet_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.spot_fleet[0].name
}

################################################################################
# Job Queue
################################################################################

locals {
  create_job_queues = var.create && var.create_job_queues
}

resource "aws_batch_job_queue" "this" {
  for_each = { for k, v in var.job_queues : k => v if local.create_job_queues }

  name                  = each.value.name
  state                 = each.value.state
  priority              = each.value.priority
  scheduling_policy_arn = try(each.value.create_scheduling_policy, true) ? aws_batch_scheduling_policy.this[each.key].arn : try(each.value.scheduling_policy_arn, null)
  compute_environments  = slice([for env in try(each.value.compute_environments, keys(var.compute_environments)) : aws_batch_compute_environment.this[env].arn], 0, min(length(try(each.value.compute_environments, keys(var.compute_environments))), 3))

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
  )
}

################################################################################
# Scheduling Policy
################################################################################

resource "aws_batch_scheduling_policy" "this" {
  for_each = { for k, v in var.job_queues : k => v if local.create_job_queues && try(v.create_scheduling_policy, true) }

  name = each.value.name

  fair_share_policy {
    compute_reservation = try(each.value.fair_share_policy.compute_reservation, null)
    share_decay_seconds = try(each.value.fair_share_policy.share_decay_seconds, null)

    dynamic "share_distribution" {
      for_each = { for k, v in try(each.value.fair_share_policy.share_distribution, {}) : k => v if can(each.value.fair_share_policy.share_distribution) }

      content {
        share_identifier = share_distribution.value.share_identifier
        weight_factor    = try(share_distribution.value.weight_factor, null)
      }
    }
  }

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
  )
}

################################################################################
# Job Definitions
################################################################################

resource "aws_batch_job_definition" "this" {
  for_each = { for k, v in var.job_definitions : k => v if var.create && var.create_job_definitions }

  name                  = try(each.value.name, each.key)
  container_properties  = try(each.value.container_properties, null)
  parameters            = try(each.value.parameters, {})
  platform_capabilities = try(each.value.platform_capabilities, null)
  type                  = try(each.value.type, "container")

  dynamic "retry_strategy" {
    for_each = try([each.value.retry_strategy], [])

    content {
      attempts = try(retry_strategy.value.attempts, null)

      dynamic "evaluate_on_exit" {
        for_each = try(retry_strategy.value.evaluate_on_exit, [])

        content {
          action           = evaluate_on_exit.value.action
          on_exit_code     = try(evaluate_on_exit.value.on_exit_code, null)
          on_reason        = try(evaluate_on_exit.value.on_reason, null)
          on_status_reason = try(evaluate_on_exit.value.on_status_reason, null)
        }
      }
    }
  }

  timeout {
    attempt_duration_seconds = try(each.value.attempt_duration_seconds, null)
  }

  propagate_tags = try(each.value.propagate_tags, null)

  tags = merge(
    var.tags, try(each.value.tags, {}),
  )
}
