variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Compute Environment(s)
################################################################################

variable "compute_environments" {
  description = "Map of compute environment definitions to create"
  type = map(object({
    name        = optional(string)
    name_prefix = optional(string)
    compute_resources = optional(object({
      allocation_strategy = optional(string)
      bid_percentage      = optional(number)
      desired_vcpus       = optional(number)
      ec2_configuration = optional(list(object({
        image_id_override = optional(string)
        image_type        = optional(string)
      })))
      ec2_key_pair   = optional(string)
      instance_role  = optional(string)
      instance_types = optional(list(string))
      launch_template = optional(object({
        launch_template_id   = optional(string)
        launch_template_name = optional(string)
        version              = optional(string)
      }))
      max_vcpus           = number
      min_vcpus           = optional(number)
      placement_group     = optional(string)
      security_group_ids  = optional(list(string))
      spot_iam_fleet_role = optional(string)
      subnets             = list(string)
      tags                = optional(map(string), {})
      type                = string
    }))
    eks_configuration = optional(object({
      eks_cluster_arn      = string
      kubernetes_namespace = string
    }))
    service_role = optional(string)
    state        = optional(string)
    tags         = optional(map(string), {})
    type         = optional(string, "MANAGED")
    update_policy = optional(object({
      job_execution_timeout_minutes = number
      terminate_jobs_on_update      = optional(bool, false)
    }))
  }))
  default = null
}

################################################################################
# Compute Environment - Instance Role
################################################################################

variable "create_instance_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "instance_iam_role_name" {
  description = "Cluster instance IAM role name"
  type        = string
  default     = null
}

variable "instance_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`instance_iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "instance_iam_role_path" {
  description = "Cluster instance IAM role path"
  type        = string
  default     = null
}

variable "instance_iam_role_description" {
  description = "Cluster instance IAM role description"
  type        = string
  default     = null
}

variable "instance_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "instance_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "instance_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Compute Environment - Service Role
################################################################################

variable "create_service_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "service_iam_role_name" {
  description = "Batch service IAM role name"
  type        = string
  default     = null
}

variable "service_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`service_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "service_iam_role_path" {
  description = "Batch service IAM role path"
  type        = string
  default     = null
}

variable "service_iam_role_description" {
  description = "Batch service IAM role description"
  type        = string
  default     = null
}

variable "service_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "service_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "service_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Compute Environment - Spot Fleet Role
################################################################################

variable "create_spot_fleet_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = false
}

variable "spot_fleet_iam_role_name" {
  description = "Spot fleet IAM role name"
  type        = string
  default     = null
}

variable "spot_fleet_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`spot_fleet_iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "spot_fleet_iam_role_path" {
  description = "Spot fleet IAM role path"
  type        = string
  default     = null
}

variable "spot_fleet_iam_role_description" {
  description = "Spot fleet IAM role description"
  type        = string
  default     = null
}

variable "spot_fleet_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "spot_fleet_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "spot_fleet_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Job Queue
################################################################################

variable "create_job_queues" {
  description = "Determines whether to create job queues"
  type        = bool
  default     = true
}

variable "job_queues" {
  description = "Map of job queue and scheduling policy defintions to create"
  type = map(object({
    compute_environment_order = map(object({
      compute_environment_key = string
      order                   = optional(number) # Will fall back to use map key as order
    }))
    job_state_time_limit_action = optional(map(object({
      action           = optional(string, "CANCEL")
      max_time_seconds = number
      reason           = optional(string)
      state            = optional(string, "RUNNABLE")
    })))
    name                  = optional(string) # Will fall back to use map key as queue name
    priority              = number
    scheduling_policy_arn = optional(string)
    state                 = optional(string, "ENABLED")
    tags                  = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string, "10m")
      update = optional(string, "10m")
      delete = optional(string, "10m")
    }))

    # Scheduling policy
    create_scheduling_policy = optional(bool, true)
    fair_share_policy = optional(object({
      compute_reservation = optional(number)
      share_decay_seconds = optional(number)
      share_distribution = optional(list(object({
        share_identifier = string
        weight_factor    = optional(number)
      })))
    }))
  }))
  default = null
}

################################################################################
# Scheduling Policy
################################################################################

# Scheduling policy is nested under job queue definition

################################################################################
# Job Definitions
################################################################################

variable "job_definitions" {
  description = "Map of job definitions to create"
  type = map(object({
    container_properties       = optional(string)
    deregister_on_new_revision = optional(bool)
    ecs_properties             = optional(string)
    eks_properties = optional(object({
      pod_properties = object({
        containers = map(object({
          args              = optional(list(string))
          command           = optional(list(string))
          env               = optional(map(string))
          image             = string
          image_pull_policy = optional(string)
          name              = optional(string) # Will fall back to use map key as container name
          resources = object({
            limits   = optional(map(string))
            requests = optional(map(string))
          })
          security_context = optional(object({
            privileged                 = optional(bool)
            read_only_root_file_system = optional(bool)
            run_as_group               = optional(number)
            run_as_non_root            = optional(bool)
            run_as_user                = optional(number)
          }))
          volume_mounts = optional(map(object({
            mount_path = string
            name       = optional(string) # Will fall back to use map key as volume mount name
            read_only  = optional(bool)
          })))
        }))
      })
      dns_policy   = optional(string)
      host_network = optional(bool)
      image_pull_secrets = optional(list(object({
        name = string
      })))
      init_containers = optional(map(object({
        args              = optional(list(string))
        command           = optional(list(string))
        env               = optional(map(string))
        image             = string
        image_pull_policy = optional(string)
        name              = optional(string) # Will fall back to use map key as init container name
        resources = object({
          limits   = optional(map(string))
          requests = optional(map(string))
        })
        security_context = optional(object({
          privileged                 = optional(bool)
          read_only_root_file_system = optional(bool)
          run_as_group               = optional(number)
          run_as_non_root            = optional(bool)
          run_as_user                = optional(number)
        }))
        volume_mounts = optional(map(object({
          mount_path = string
          name       = optional(string) # Will fall back to use map key as volume mount name
          read_only  = optional(bool)
        })))
      })))
      metadata = optional(object({
        labels = optional(map(string))
      }))
      service_account_name    = optional(string)
      share_process_namespace = optional(bool)
      volumes = optional(map(object({
        empty_dir = optional(object({
          medium     = optional(string)
          size_limit = optional(string)
        }))
        host_path = optional(object({
          path = string
        }))
        name = optional(string) # Will fall back to use map key as volume name
        secret = optional(object({
          optional    = optional(bool)
          secret_name = string
        }))
      })))
    }))
    name                  = optional(string) # Will fall back to use map key as job definition name
    node_properties       = optional(string)
    parameters            = optional(map(string))
    platform_capabilities = optional(list(string))
    propagate_tags        = optional(bool)
    retry_strategy = optional(object({
      attempts = optional(number)
      evaluate_on_exit = optional(map(object({
        action           = string
        on_exit_code     = optional(string)
        on_reason        = optional(string)
        on_status_reason = optional(string)
      })))
    }))
    scheduling_priority = optional(number)
    tags                = optional(map(string), {})
    timeout = optional(object({
      attempt_duration_seconds = optional(number)
    }))
    type = optional(string, "container")
  }))
  default = null
}
