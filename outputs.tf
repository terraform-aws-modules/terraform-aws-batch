################################################################################
# Compute Environment(s)
################################################################################

output "compute_environments" {
  description = "Map of compute environments created and their associated attributes"
  value       = aws_batch_compute_environment.this
}

################################################################################
# Compute Environment - Instance Role
################################################################################

output "instance_iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.instance[0].name, null)
}

output "instance_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.instance[0].arn, null)
}

output "instance_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.instance[0].unique_id, null)
}

output "instance_iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = try(aws_iam_instance_profile.instance[0].arn, null)
}

output "instance_iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = try(aws_iam_instance_profile.instance[0].id, null)
}

output "instance_iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = try(aws_iam_instance_profile.instance[0].unique_id, null)
}

################################################################################
# Compute Environment - Service Role
################################################################################

output "service_iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.service[0].name, null)
}

output "service_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.service[0].arn, null)
}

output "service_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.service[0].unique_id, null)
}

################################################################################
# Compute Environment - Spot Fleet Role
################################################################################

output "spot_fleet_iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.spot_fleet[0].name, null)
}

output "spot_fleet_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.spot_fleet[0].arn, null)
}

output "spot_fleet_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.spot_fleet[0].unique_id, null)
}

################################################################################
# Job Queue
################################################################################

output "job_queues" {
  description = "Map of job queues created and their associated attributes"
  value       = aws_batch_job_queue.this
}

################################################################################
# Scheduling Policy
################################################################################

output "scheduling_policies" {
  description = "Map of scheduling policies created and their associated attributes"
  value       = aws_batch_scheduling_policy.this
}

################################################################################
# Job Definitions
################################################################################

output "job_definitions" {
  description = "Map of job defintions created and their associated attributes"
  value       = aws_batch_job_definition.this
}
