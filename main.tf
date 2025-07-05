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
  for_each = var.create && var.compute_environments != null ? var.compute_environments : {}

  region = var.region

  name        = each.value.name
  name_prefix = each.value.name_prefix != null ? "${each.value.name_prefix}-" : null

  dynamic "compute_resources" {
    for_each = each.value.compute_resources != null ? [each.value.compute_resources] : []

    content {
      allocation_strategy = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : compute_resources.value.allocation_strategy
      bid_percentage      = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : compute_resources.value.bid_percentage
      desired_vcpus       = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : compute_resources.value.desired_vcpus

      dynamic "ec2_configuration" {
        for_each = !contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) && compute_resources.value.ec2_configuration != null ? compute_resources.value.ec2_configuration : []

        content {
          image_id_override = ec2_configuration.value.image_id_override
          image_type        = ec2_configuration.value.image_type
        }
      }

      ec2_key_pair  = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : compute_resources.value.ec2_key_pair
      instance_role = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : try(aws_iam_instance_profile.instance[0].arn, compute_resources.value.instance_role)
      instance_type = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : compute_resources.value.instance_types

      dynamic "launch_template" {
        for_each = !contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) && compute_resources.value.launch_template != null ? [compute_resources.value.launch_template] : []

        content {
          launch_template_id   = launch_template.value.launch_template_id
          launch_template_name = launch_template.value.launch_template_name
          version              = launch_template.value.version
        }
      }

      max_vcpus           = compute_resources.value.max_vcpus
      min_vcpus           = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : compute_resources.value.min_vcpus
      placement_group     = compute_resources.value.placement_group
      security_group_ids  = compute_resources.value.security_group_ids
      spot_iam_fleet_role = compute_resources.value.type == "SPOT" ? try(aws_iam_role.spot_fleet[0].arn, compute_resources.value.spot_fleet_role) : null
      subnets             = compute_resources.value.subnets
      # We do not merge with default `var.tags` here because tag changes cause compute environment replacement
      tags = contains(["FARGATE", "FARGATE_SPOT"], compute_resources.value.type) ? null : compute_resources.value.tags
      type = compute_resources.value.type
    }
  }

  dynamic "eks_configuration" {
    for_each = each.value.eks_configuration != null ? [each.value.eks_configuration] : []

    content {
      eks_cluster_arn      = eks_configuration.value.eks_cluster_arn
      kubernetes_namespace = eks_configuration.value.kubernetes_namespace
    }
  }

  service_role = var.create_service_iam_role ? aws_iam_role.service[0].arn : each.value.service_role
  state        = each.value.state

  tags = merge(
    { terraform-aws-modules = "batch" },
    var.tags,
    each.value.tags,
  )

  type = each.value.type

  dynamic "update_policy" {
    for_each = each.value.update_policy != null ? [each.value.update_policy] : []

    content {
      job_execution_timeout_minutes = update_policy.value.job_execution_timeout_minutes
      terminate_jobs_on_update      = update_policy.value.terminate_jobs_on_update
    }
  }

  # Prevent a race condition during environment deletion, otherwise the policy may be destroyed
  # too soon and the compute environment will then get stuck in the `DELETING` state
  depends_on = [
    aws_iam_role_policy_attachment.instance,
    aws_iam_role_policy_attachment.service,
    aws_iam_role_policy_attachment.spot_fleet,
  ]

  lifecycle {
    create_before_destroy = true
  }
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
    sid     = "EC2AssumeRole"
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

  tags = merge(
    var.tags,
    var.instance_iam_role_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
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

  tags = merge(
    var.tags,
    var.instance_iam_role_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
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
    sid     = "BatchAssumeRole"
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

  tags = merge(
    var.tags,
    var.service_iam_role_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
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
    sid     = "SpotFleetAssumeRole"
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

  tags = merge(
    var.tags,
    var.spot_fleet_iam_role_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
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
  for_each = local.create_job_queues && var.job_queues != null ? var.job_queues : {}

  region = var.region

  dynamic "compute_environment_order" {
    for_each = each.value.compute_environment_order != null ? each.value.compute_environment_order : {}

    content {
      # Refer to compute environment created above by the user provided configuration definition key
      compute_environment = aws_batch_compute_environment.this[compute_environment_order.value.compute_environment_key].arn
      order               = try(coalesce(compute_environment_order.value.order, compute_environment_order.key), null)
    }
  }

  dynamic "job_state_time_limit_action" {
    for_each = each.value.job_state_time_limit_action != null ? each.value.job_state_time_limit_action : {}

    content {
      action           = job_state_time_limit_action.value.action
      max_time_seconds = job_state_time_limit_action.value.max_time_seconds
      reason           = job_state_time_limit_action.value.reason
      state            = job_state_time_limit_action.value.state
    }
  }

  name                  = try(coalesce(each.value.name, each.key), null)
  priority              = each.value.priority
  scheduling_policy_arn = each.value.create_scheduling_policy ? aws_batch_scheduling_policy.this[each.key].arn : each.value.scheduling_policy_arn
  state                 = each.value.state

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
  )

  depends_on = [
    aws_batch_compute_environment.this,
  ]
}

################################################################################
# Scheduling Policy
################################################################################

resource "aws_batch_scheduling_policy" "this" {
  for_each = local.create_job_queues && var.job_queues != null ? { for k, v in var.job_queues : k => v if v.create_scheduling_policy } : {}

  region = var.region

  dynamic "fair_share_policy" {
    for_each = each.value.fair_share_policy != null ? [each.value.fair_share_policy] : []

    content {
      compute_reservation = fair_share_policy.value.compute_reservation
      share_decay_seconds = fair_share_policy.value.share_decay_seconds

      dynamic "share_distribution" {
        for_each = fair_share_policy.value.share_distribution != null ? fair_share_policy.value.share_distribution : []

        content {
          share_identifier = share_distribution.value.share_identifier
          weight_factor    = share_distribution.value.weight_factor
        }
      }
    }
  }

  name = each.value.name

  tags = merge(
    var.tags,
    each.value.tags,
  )
}

################################################################################
# Job Definitions
################################################################################

resource "aws_batch_job_definition" "this" {
  for_each = var.create && var.job_definitions != null ? var.job_definitions : {}

  region = var.region

  container_properties       = each.value.container_properties
  deregister_on_new_revision = each.value.deregister_on_new_revision
  ecs_properties             = each.value.ecs_properties

  dynamic "eks_properties" {
    for_each = each.value.eks_properties != null ? [each.value.eks_properties] : []

    content {
      pod_properties {
        dynamic "containers" {
          for_each = eks_properties.value.pod_properties.containers

          content {
            args    = containers.value.args
            command = containers.value.command

            dynamic "env" {
              for_each = containers.value.env != null ? containers.value.env : {}

              content {
                name  = env.key
                value = env.value
              }
            }

            image             = containers.value.image
            image_pull_policy = containers.value.image_pull_policy
            name              = try(coalesce(containers.value.name, containers.key), null)

            dynamic "resources" {
              for_each = containers.value.resources != null ? [containers.value.resources] : []

              content {
                limits   = resources.value.limits
                requests = resources.value.requests
              }
            }

            dynamic "security_context" {
              for_each = containers.value.security_context != null ? [containers.value.security_context] : []

              content {
                privileged                 = security_context.value.privileged
                read_only_root_file_system = security_context.value.read_only_root_file_system
                run_as_group               = security_context.value.run_as_group
                run_as_non_root            = security_context.value.run_as_non_root
                run_as_user                = security_context.value.run_as_user
              }
            }

            dynamic "volume_mounts" {
              for_each = containers.value.volume_mounts != null ? containers.value.volume_mounts : {}

              content {
                mount_path = volume_mounts.value.mount_path
                name       = try(coalesce(volume_mounts.value.name, volume_mounts.key), null)
                read_only  = volume_mounts.value.read_only
              }
            }
          }
        }

        dns_policy   = eks_properties.value.dns_policy
        host_network = eks_properties.value.host_network

        dynamic "image_pull_secret" {
          for_each = eks_properties.value.image_pull_secrets != null ? eks_properties.value.image_pull_secrets : []

          content {
            name = image_pull_secret.value.name
          }
        }

        dynamic "init_containers" {
          for_each = eks_properties.value.init_containers != null ? eks_properties.value.init_containers : {}

          content {
            args    = init_containers.value.args
            command = init_containers.value.command

            dynamic "env" {
              for_each = init_containers.value.env != null ? init_containers.value.env : {}

              content {
                name  = env.key
                value = env.value
              }
            }

            image             = init_containers.value.image
            image_pull_policy = init_containers.value.image_pull_policy
            name              = try(coalesce(init_containers.value.name, init_containers.key), null)

            dynamic "resources" {
              for_each = init_containers.value.resources != null ? [init_containers.value.resources] : []

              content {
                limits   = resources.value.limits
                requests = resources.value.requests
              }
            }

            dynamic "security_context" {
              for_each = init_containers.value.security_context != null ? [init_containers.value.security_context] : []

              content {
                privileged                 = security_context.value.privileged
                read_only_root_file_system = security_context.value.read_only_root_file_system
                run_as_group               = security_context.value.run_as_group
                run_as_non_root            = security_context.value.run_as_non_root
                run_as_user                = security_context.value.run_as_user
              }
            }

            dynamic "volume_mounts" {
              for_each = init_containers.value.volume_mounts != null ? init_containers.value.volume_mounts : {}

              content {
                mount_path = volume_mounts.value.mount_path
                name       = try(coalesce(volume_mounts.value.name, volume_mounts.key), null)
                read_only  = volume_mounts.value.read_only
              }
            }
          }
        }

        dynamic "metadata" {
          for_each = eks_properties.value.metadata != null ? [eks_properties.value.metadata] : []

          content {
            labels = metadata.value.labels
          }
        }

        service_account_name    = eks_properties.value.service_account_name
        share_process_namespace = eks_properties.value.share_process_namespace

        dynamic "volumes" {
          for_each = eks_properties.value.volumes != null ? eks_properties.value.volumes : {}

          content {
            dynamic "empty_dir" {
              for_each = volumes.value.empty_dir != null ? [volumes.value.empty_dir] : []

              content {
                medium     = empty_dir.value.medium
                size_limit = empty_dir.value.size_limit
              }
            }

            dynamic "host_path" {
              for_each = volumes.value.host_path != null ? [volumes.value.host_path] : []

              content {
                path = host_path.value.path
              }
            }

            name = try(coalesce(volumes.value.name, volumes.key), null)

            dynamic "secret" {
              for_each = volumes.value.secret != null ? [volumes.value.secret] : []

              content {
                optional    = secret.value.optional
                secret_name = secret.value.secret_name
              }
            }
          }
        }
      }
    }
  }

  name                  = try(coalesce(each.value.name, each.key), null)
  node_properties       = each.value.node_properties
  parameters            = each.value.parameters
  platform_capabilities = each.value.platform_capabilities
  propagate_tags        = each.value.propagate_tags

  dynamic "retry_strategy" {
    for_each = each.value.retry_strategy != null ? [each.value.retry_strategy] : []

    content {
      attempts = retry_strategy.value.attempts

      dynamic "evaluate_on_exit" {
        for_each = retry_strategy.value.evaluate_on_exit != null ? retry_strategy.value.evaluate_on_exit : {}

        content {
          action           = evaluate_on_exit.value.action
          on_exit_code     = evaluate_on_exit.value.on_exit_code
          on_reason        = evaluate_on_exit.value.on_reason
          on_status_reason = evaluate_on_exit.value.on_status_reason
        }
      }
    }
  }

  scheduling_priority = each.value.scheduling_priority
  tags = merge(
    var.tags,
    each.value.tags,
  )

  dynamic "timeout" {
    for_each = each.value.timeout != null ? [each.value.timeout] : []

    content {
      attempt_duration_seconds = timeout.value.attempt_duration_seconds
    }
  }

  type = each.value.type
}
