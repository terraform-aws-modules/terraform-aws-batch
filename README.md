# AWS Batch Terraform module

Terraform module which creates AWS Batch resources.

## Usage

See [`examples`](https://github.com/terraform-aws-modules/terraform-aws-batch/tree/master/examples) directory for working examples to reference:

```hcl
module "batch" {
  source = "terraform-aws-modules/batch/aws"

  compute_environments = {
    a_ec2 = {
      name_prefix = "ec2"

      compute_resources = {
        type           = "EC2"
        min_vcpus      = 4
        max_vcpus      = 16
        desired_vcpus  = 4
        instance_types = ["m5.large", "r5.large"]

        security_group_ids = ["sg-f1d03a88"]
        subnets            = ["subnet-30ef7b3c", "subnet-1ecda77b", "subnet-ca09ddbc"]

        tags = {
          # This will set the name on the Ec2 instances launched by this compute environment
          Name = "example"
          Type = "Ec2"
        }
      }
    }

    b_ec2_spot = {
      name_prefix = "ec2_spot"

      compute_resources = {
        type                = "SPOT"
        allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
        bid_percentage      = 20

        min_vcpus      = 4
        max_vcpus      = 16
        desired_vcpus  = 4
        instance_types = ["m4.large", "m3.large", "r4.large", "r3.large"]

        security_group_ids = ["sg-f1d03a88"]
        subnets            = ["subnet-30ef7b3c", "subnet-1ecda77b", "subnet-ca09ddbc"]

        tags = {
          # This will set the name on the Ec2 instances launched by this compute environment
          Name = "example-spot"
          Type = "Ec2Spot"
        }
      }
    }
  }

  # Job queus and scheduling policies
  job_queues = {
    low_priority = {
      name     = "LowPriorityEc2"
      state    = "ENABLED"
      priority = 1

      compute_environment_order = {
        0 = {
          compute_environment_key = "b_ec2_spot"
        }
        1 = {
          compute_environment_key = "a_ec2"
        }
      }

      tags = {
        JobQueue = "Low priority job queue"
      }
    }

    high_priority = {
      name     = "HighPriorityEc2"
      state    = "ENABLED"
      priority = 99

      compute_environment_order = {
        0 = {
          compute_environment_key = "a_ec2"
        }
      }

      fair_share_policy = {
        compute_reservation = 1
        share_decay_seconds = 3600

        share_distribution = [{
          share_identifier = "A1*"
          weight_factor    = 0.1
          }, {
          share_identifier = "A2"
          weight_factor    = 0.2
        }]
      }

      tags = {
        JobQueue = "High priority job queue"
      }
    }
  }

  job_definitions = {
    example = {
      name           = "example"
      propagate_tags = true

      container_properties = jsonencode({
        command = ["ls", "-la"]
        image   = "public.ecr.aws/runecast/busybox:1.33.1"
        resourceRequirements = [
          { type = "VCPU", value = "1" },
          { type = "MEMORY", value = "1024" }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/aws/batch/example"
            awslogs-region        = "us-east-1"
            awslogs-stream-prefix = "ec2"
          }
        }
      })

      attempt_duration_seconds = 60
      retry_strategy = {
        attempts = 3
        evaluate_on_exit = {
          retry_error = {
            action       = "RETRY"
            on_exit_code = 1
          }
          exit_success = {
            action       = "EXIT"
            on_exit_code = 0
          }
        }
      }

      tags = {
        JobDefinition = "Example"
      }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

## Examples

Examples codified under the [`examples`](https://github.com/terraform-aws-modules/terraform-aws-batch/tree/master/examples) are intended to give users references for how to use the module(s) as well as testing/validating changes to the source code of the module. If contributing to the project, please be sure to make any appropriate updates to the relevant examples to allow maintainers to test your changes and to keep the examples up to date for users. Thank you!

- [EC2](https://github.com/terraform-aws-modules/terraform-aws-batch/tree/master/examples/ec2)
- [Fargate](https://github.com/terraform-aws-modules/terraform-aws-batch/tree/master/examples/fargate)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_batch_compute_environment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment) | resource |
| [aws_batch_job_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_definition) | resource |
| [aws_batch_job_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_queue) | resource |
| [aws_batch_scheduling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_scheduling_policy) | resource |
| [aws_iam_instance_profile.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.spot_fleet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.spot_fleet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.spot_fleet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_environments"></a> [compute\_environments](#input\_compute\_environments) | Map of compute environment definitions to create | <pre>map(object({<br/>    name        = optional(string)<br/>    name_prefix = optional(string)<br/>    compute_resources = optional(object({<br/>      allocation_strategy = optional(string)<br/>      bid_percentage      = optional(number)<br/>      desired_vcpus       = optional(number)<br/>      ec2_configuration = optional(list(object({<br/>        image_id_override = optional(string)<br/>        image_type        = optional(string)<br/>      })))<br/>      ec2_key_pair   = optional(string)<br/>      instance_role  = optional(string)<br/>      instance_types = optional(list(string))<br/>      launch_template = optional(object({<br/>        launch_template_id   = optional(string)<br/>        launch_template_name = optional(string)<br/>        version              = optional(string)<br/>      }))<br/>      max_vcpus           = number<br/>      min_vcpus           = optional(number)<br/>      placement_group     = optional(string)<br/>      security_group_ids  = optional(list(string))<br/>      spot_iam_fleet_role = optional(string)<br/>      subnets             = list(string)<br/>      tags                = optional(map(string), {})<br/>      type                = string<br/>    }))<br/>    eks_configuration = optional(object({<br/>      eks_cluster_arn      = string<br/>      kubernetes_namespace = string<br/>    }))<br/>    service_role = optional(string)<br/>    state        = optional(string)<br/>    tags         = optional(map(string), {})<br/>    type         = optional(string, "MANAGED")<br/>    update_policy = optional(object({<br/>      job_execution_timeout_minutes = number<br/>      terminate_jobs_on_update      = optional(bool, false)<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_instance_iam_role"></a> [create\_instance\_iam\_role](#input\_create\_instance\_iam\_role) | Determines whether a an IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_job_queues"></a> [create\_job\_queues](#input\_create\_job\_queues) | Determines whether to create job queues | `bool` | `true` | no |
| <a name="input_create_service_iam_role"></a> [create\_service\_iam\_role](#input\_create\_service\_iam\_role) | Determines whether a an IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_spot_fleet_iam_role"></a> [create\_spot\_fleet\_iam\_role](#input\_create\_spot\_fleet\_iam\_role) | Determines whether a an IAM role is created or to use an existing IAM role | `bool` | `false` | no |
| <a name="input_instance_iam_role_additional_policies"></a> [instance\_iam\_role\_additional\_policies](#input\_instance\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| <a name="input_instance_iam_role_description"></a> [instance\_iam\_role\_description](#input\_instance\_iam\_role\_description) | Cluster instance IAM role description | `string` | `null` | no |
| <a name="input_instance_iam_role_name"></a> [instance\_iam\_role\_name](#input\_instance\_iam\_role\_name) | Cluster instance IAM role name | `string` | `null` | no |
| <a name="input_instance_iam_role_path"></a> [instance\_iam\_role\_path](#input\_instance\_iam\_role\_path) | Cluster instance IAM role path | `string` | `null` | no |
| <a name="input_instance_iam_role_permissions_boundary"></a> [instance\_iam\_role\_permissions\_boundary](#input\_instance\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_instance_iam_role_tags"></a> [instance\_iam\_role\_tags](#input\_instance\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_instance_iam_role_use_name_prefix"></a> [instance\_iam\_role\_use\_name\_prefix](#input\_instance\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`instance_iam_role_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_job_definitions"></a> [job\_definitions](#input\_job\_definitions) | Map of job definitions to create | <pre>map(object({<br/>    container_properties       = optional(string)<br/>    deregister_on_new_revision = optional(bool)<br/>    ecs_properties             = optional(string)<br/>    eks_properties = optional(object({<br/>      pod_properties = object({<br/>        containers = map(object({<br/>          args              = optional(list(string))<br/>          command           = optional(list(string))<br/>          env               = optional(map(string))<br/>          image             = string<br/>          image_pull_policy = optional(string)<br/>          name              = optional(string) # Will fall back to use map key as container name<br/>          resources = object({<br/>            limits   = optional(map(string))<br/>            requests = optional(map(string))<br/>          })<br/>          security_context = optional(object({<br/>            privileged                 = optional(bool)<br/>            read_only_root_file_system = optional(bool)<br/>            run_as_group               = optional(number)<br/>            run_as_non_root            = optional(bool)<br/>            run_as_user                = optional(number)<br/>          }))<br/>          volume_mounts = optional(map(object({<br/>            mount_path = string<br/>            name       = optional(string) # Will fall back to use map key as volume mount name<br/>            read_only  = optional(bool)<br/>          })))<br/>        }))<br/>      })<br/>      dns_policy   = optional(string)<br/>      host_network = optional(bool)<br/>      image_pull_secrets = optional(list(object({<br/>        name = string<br/>      })))<br/>      init_containers = optional(map(object({<br/>        args              = optional(list(string))<br/>        command           = optional(list(string))<br/>        env               = optional(map(string))<br/>        image             = string<br/>        image_pull_policy = optional(string)<br/>        name              = optional(string) # Will fall back to use map key as init container name<br/>        resources = object({<br/>          limits   = optional(map(string))<br/>          requests = optional(map(string))<br/>        })<br/>        security_context = optional(object({<br/>          privileged                 = optional(bool)<br/>          read_only_root_file_system = optional(bool)<br/>          run_as_group               = optional(number)<br/>          run_as_non_root            = optional(bool)<br/>          run_as_user                = optional(number)<br/>        }))<br/>        volume_mounts = optional(map(object({<br/>          mount_path = string<br/>          name       = optional(string) # Will fall back to use map key as volume mount name<br/>          read_only  = optional(bool)<br/>        })))<br/>      })))<br/>      metadata = optional(object({<br/>        labels = optional(map(string))<br/>      }))<br/>      service_account_name    = optional(string)<br/>      share_process_namespace = optional(bool)<br/>      volumes = optional(map(object({<br/>        empty_dir = optional(object({<br/>          medium     = optional(string)<br/>          size_limit = optional(string)<br/>        }))<br/>        host_path = optional(object({<br/>          path = string<br/>        }))<br/>        name = optional(string) # Will fall back to use map key as volume name<br/>        secret = optional(object({<br/>          optional    = optional(bool)<br/>          secret_name = string<br/>        }))<br/>      })))<br/>    }))<br/>    name                  = optional(string) # Will fall back to use map key as job definition name<br/>    node_properties       = optional(string)<br/>    parameters            = optional(map(string))<br/>    platform_capabilities = optional(list(string))<br/>    propagate_tags        = optional(bool)<br/>    retry_strategy = optional(object({<br/>      attempts = optional(number)<br/>      evaluate_on_exit = optional(map(object({<br/>        action           = string<br/>        on_exit_code     = optional(string)<br/>        on_reason        = optional(string)<br/>        on_status_reason = optional(string)<br/>      })))<br/>    }))<br/>    scheduling_priority = optional(number)<br/>    tags                = optional(map(string), {})<br/>    timeout = optional(object({<br/>      attempt_duration_seconds = optional(number)<br/>    }))<br/>    type = optional(string, "container")<br/>  }))</pre> | `null` | no |
| <a name="input_job_queues"></a> [job\_queues](#input\_job\_queues) | Map of job queue and scheduling policy defintions to create | <pre>map(object({<br/>    compute_environment_order = map(object({<br/>      compute_environment_key = string<br/>      order                   = optional(number) # Will fall back to use map key as order<br/>    }))<br/>    job_state_time_limit_action = optional(map(object({<br/>      action           = optional(string, "CANCEL")<br/>      max_time_seconds = number<br/>      reason           = optional(string)<br/>      state            = optional(string, "RUNNABLE")<br/>    })))<br/>    name                  = optional(string) # Will fall back to use map key as queue name<br/>    priority              = number<br/>    scheduling_policy_arn = optional(string)<br/>    state                 = optional(string, "ENABLED")<br/>    tags                  = optional(map(string), {})<br/>    timeouts = optional(object({<br/>      create = optional(string, "10m")<br/>      update = optional(string, "10m")<br/>      delete = optional(string, "10m")<br/>    }))<br/><br/>    # Scheduling policy<br/>    create_scheduling_policy = optional(bool, true)<br/>    fair_share_policy = optional(object({<br/>      compute_reservation = optional(number)<br/>      share_decay_seconds = optional(number)<br/>      share_distribution = optional(list(object({<br/>        share_identifier = string<br/>        weight_factor    = optional(number)<br/>      })))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_service_iam_role_additional_policies"></a> [service\_iam\_role\_additional\_policies](#input\_service\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| <a name="input_service_iam_role_description"></a> [service\_iam\_role\_description](#input\_service\_iam\_role\_description) | Batch service IAM role description | `string` | `null` | no |
| <a name="input_service_iam_role_name"></a> [service\_iam\_role\_name](#input\_service\_iam\_role\_name) | Batch service IAM role name | `string` | `null` | no |
| <a name="input_service_iam_role_path"></a> [service\_iam\_role\_path](#input\_service\_iam\_role\_path) | Batch service IAM role path | `string` | `null` | no |
| <a name="input_service_iam_role_permissions_boundary"></a> [service\_iam\_role\_permissions\_boundary](#input\_service\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_service_iam_role_tags"></a> [service\_iam\_role\_tags](#input\_service\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_service_iam_role_use_name_prefix"></a> [service\_iam\_role\_use\_name\_prefix](#input\_service\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`service_iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_spot_fleet_iam_role_additional_policies"></a> [spot\_fleet\_iam\_role\_additional\_policies](#input\_spot\_fleet\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| <a name="input_spot_fleet_iam_role_description"></a> [spot\_fleet\_iam\_role\_description](#input\_spot\_fleet\_iam\_role\_description) | Spot fleet IAM role description | `string` | `null` | no |
| <a name="input_spot_fleet_iam_role_name"></a> [spot\_fleet\_iam\_role\_name](#input\_spot\_fleet\_iam\_role\_name) | Spot fleet IAM role name | `string` | `null` | no |
| <a name="input_spot_fleet_iam_role_path"></a> [spot\_fleet\_iam\_role\_path](#input\_spot\_fleet\_iam\_role\_path) | Spot fleet IAM role path | `string` | `null` | no |
| <a name="input_spot_fleet_iam_role_permissions_boundary"></a> [spot\_fleet\_iam\_role\_permissions\_boundary](#input\_spot\_fleet\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_spot_fleet_iam_role_tags"></a> [spot\_fleet\_iam\_role\_tags](#input\_spot\_fleet\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_spot_fleet_iam_role_use_name_prefix"></a> [spot\_fleet\_iam\_role\_use\_name\_prefix](#input\_spot\_fleet\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`spot_fleet_iam_role_name`) is used as a prefix | `string` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compute_environments"></a> [compute\_environments](#output\_compute\_environments) | Map of compute environments created and their associated attributes |
| <a name="output_instance_iam_instance_profile_arn"></a> [instance\_iam\_instance\_profile\_arn](#output\_instance\_iam\_instance\_profile\_arn) | ARN assigned by AWS to the instance profile |
| <a name="output_instance_iam_instance_profile_id"></a> [instance\_iam\_instance\_profile\_id](#output\_instance\_iam\_instance\_profile\_id) | Instance profile's ID |
| <a name="output_instance_iam_instance_profile_unique"></a> [instance\_iam\_instance\_profile\_unique](#output\_instance\_iam\_instance\_profile\_unique) | Stable and unique string identifying the IAM instance profile |
| <a name="output_instance_iam_role_arn"></a> [instance\_iam\_role\_arn](#output\_instance\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_instance_iam_role_name"></a> [instance\_iam\_role\_name](#output\_instance\_iam\_role\_name) | The name of the IAM role |
| <a name="output_instance_iam_role_unique_id"></a> [instance\_iam\_role\_unique\_id](#output\_instance\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_job_definitions"></a> [job\_definitions](#output\_job\_definitions) | Map of job defintions created and their associated attributes |
| <a name="output_job_queues"></a> [job\_queues](#output\_job\_queues) | Map of job queues created and their associated attributes |
| <a name="output_scheduling_policies"></a> [scheduling\_policies](#output\_scheduling\_policies) | Map of scheduling policies created and their associated attributes |
| <a name="output_service_iam_role_arn"></a> [service\_iam\_role\_arn](#output\_service\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_service_iam_role_name"></a> [service\_iam\_role\_name](#output\_service\_iam\_role\_name) | The name of the IAM role |
| <a name="output_service_iam_role_unique_id"></a> [service\_iam\_role\_unique\_id](#output\_service\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_spot_fleet_iam_role_arn"></a> [spot\_fleet\_iam\_role\_arn](#output\_spot\_fleet\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_spot_fleet_iam_role_name"></a> [spot\_fleet\_iam\_role\_name](#output\_spot\_fleet\_iam\_role\_name) | The name of the IAM role |
| <a name="output_spot_fleet_iam_role_unique_id"></a> [spot\_fleet\_iam\_role\_unique\_id](#output\_spot\_fleet\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-batch/blob/master/LICENSE).
