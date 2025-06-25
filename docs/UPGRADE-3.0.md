# Upgrade from v2.x to v3.x

If you have any questions regarding this upgrade process, please consult the `examples` directory:

- [EC2](https://github.com/terraform-aws-modules/terraform-aws-batch/tree/master/examples/ec2)
- [Fargate](https://github.com/terraform-aws-modules/terraform-aws-batch/tree/master/examples/fargate)

If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Terraform v1.5.7 is now minimum supported version
- AWS provider v6.0.0 is now minimum supported version
- `instance_iam_role_additional_policies`, `service_iam_role_additional_policies`, `spot_fleet_iam_role_additional_policies` types are now `map(string)` instead of `list(string)`
- IAM assume role policy SIDs have been modified to match their use (previously all were `ECSAssumeRole` which is inaccurate)
- `compute_environment_order` is now a required argument for `aws_batch_job_queue` per the Batch API and replaces `compute_environments`

## Additional changes

### Added

- Support for `region` parameter to specify the AWS region for the resources created if different from the provider region.
- Support for `compute_environment_order`, `job_state_time_limit_action`, `timeouts` arguments for job queues
- All (currently) supported arguments for `eks_properties` argument have been added to the job definition resource
- Support for `scheduling_priority` and `node_properties` arguments for job definitions

### Modified

- Variable definitions now contain detailed `object` types in place of the previously used any type.
- `compute_environment_name` argument has been changed to `name` per provider `v6.x` API; no-op for users
- `compute_environment_name_prefix` argument has been changed to `name_prefix` per provider `v6.x` API; no-op for users

### Removed

- None

### Variable and output changes

1. Removed variables:

   - None

2. Renamed variables:

   - None

3. Added variables:

   - None

4. Removed outputs:

   - None

5. Renamed outputs:

   - None

6. Added outputs:

   - None

## Upgrade State Migrations

### Before 2.x Example

```hcl
module "batch" {
  source  = "terraform-aws-modules/batch/aws"
  version = "2.1.0"

  # Truncated for brevity, only relevant module API changes are shown ...

  instance_iam_role_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  compute_environments = {
    a_ec2 = {
      ... # Other properties for a_ec2 compute environment
    }

    b_ec2_spot = {
      ... # Other properties for b_ec2_spot compute environment
    }
  }

  tags = local.tags
}
```

### After 3.x Example

```hcl
module "batch" {
  source  = "terraform-aws-modules/batch/aws"
  version = "3.0.0"

  # Truncated for brevity, only relevant module API changes are shown ...

  instance_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  compute_environments = {
    a_ec2 = {
      ... # Other properties for a_ec2 compute environment
    }

    b_ec2_spot = {
      ... # Other properties for b_ec2_spot compute environment
    }
  }
  # Now required
  compute_environment_order = {
    0 = {
      compute_environment_key = "a_ec2"
    }
    1 = {
      compute_environment_key = "b_ec2_spot"
    }
  }

  tags = local.tags
}
```

To migrate from the `v2.x` version to `v3.x` version example shown above, the following state move commands can be performed to maintain the current resources without modification:

```bash
# For each additional policy in instance_iam_role_additional_policies, simply move the prior value to the new key you have defined in your configuration
# This can be done similarly for aws_iam_role_policy_attachment.service and aws_iam_role_policy_attachment.spot_fleet
terraform state mv \
  'module.batch.aws_iam_role_policy_attachment.instance["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]' \
  'module.batch.aws_iam_role_policy_attachment.instance["AmazonSSMManagedInstanceCore"]'
```
