################################################################################
# Compute Environment(s)
################################################################################

output "compute_environments" {
  description = "Map of compute environments created and their associated attributes"
  value       = module.batch.compute_environments
}

################################################################################
# Compute Environment - Instance Role
################################################################################

output "instance_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.batch.instance_iam_role_name
}

output "instance_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.batch.instance_iam_role_arn
}

output "instance_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.batch.instance_iam_role_unique_id
}

output "instance_iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.batch.instance_iam_instance_profile_arn
}

output "instance_iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = module.batch.instance_iam_instance_profile_id
}

output "instance_iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = module.batch.instance_iam_instance_profile_unique
}

################################################################################
# Compute Environment - Service Role
################################################################################

output "service_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.batch.service_iam_role_name
}

output "service_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.batch.service_iam_role_arn
}

output "service_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.batch.service_iam_role_unique_id
}

################################################################################
# Compute Environment - Spot Fleet Role
################################################################################

output "spot_fleet_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.batch.spot_fleet_iam_role_name
}

output "spot_fleet_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.batch.spot_fleet_iam_role_arn
}

output "spot_fleet_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.batch.spot_fleet_iam_role_unique_id
}

################################################################################
# Job Queue
################################################################################

output "job_queues" {
  description = "Map of job queues created and their associated attributes"
  value       = module.batch.job_queues
}

################################################################################
# Scheduling Policy
################################################################################

output "scheduling_policies" {
  description = "Map of scheduling policies created and their associated attributes"
  value       = module.batch.scheduling_policies
}

################################################################################
# Job Definitions
################################################################################

output "job_definitions" {
  description = "Map of job defintions created and their associated attributes"
  value       = module.batch.job_definitions
}
