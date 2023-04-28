# AWS Batch Example - EC2

Configuration in this directory creates:

- AWS Batch compute environments using managed EC2, managed EC2 Spot, and unmanaged EC2
- AWS Batch job queue for high priority tasks with scheduling policy
- AWS Batch job queue for low priority tasks
- AWS Batch job definition using busybox container image

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_batch"></a> [batch](#module\_batch) | ../.. | n/a |
| <a name="module_batch_disabled"></a> [batch\_disabled](#module\_batch\_disabled) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 4.0 |
| <a name="module_vpc_endpoint_security_group"></a> [vpc\_endpoint\_security\_group](#module\_vpc\_endpoint\_security\_group) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

No inputs.

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
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-batch/blob/master/LICENSE).
