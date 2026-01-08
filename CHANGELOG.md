# Changelog

All notable changes to this project will be documented in this file.

## [3.1.0](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v3.0.5...v3.1.0) (2026-01-08)

### Features

* Add provider meta user-agent, replacing static tag ([#51](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/51)) ([9368b72](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/9368b7295134146582b5472f9fb350c9d048f811))

## [3.0.5](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v3.0.4...v3.0.5) (2025-10-21)

### Bug Fixes

* Update CI workflow versions to latest ([#50](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/50)) ([71b03c6](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/71b03c6a0d023cfb8b0d2ebdc5ca59b34ae3d6fc))

## [3.0.4](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v3.0.3...v3.0.4) (2025-08-25)


### Bug Fixes

* Correct attribute name for external spot IAM role ([#49](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/49)) ([44828cb](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/44828cbe2e18e57b2be54ddb6be98e886d97a4b9))

## [3.0.3](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v3.0.2...v3.0.3) (2025-07-05)


### Bug Fixes

* Ensure a list of attributes can be used on `ec2_configuration` ([#47](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/47)) ([67d405f](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/67d405f14892f314512ff09119513e9bcf81da91))

## [3.0.2](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v3.0.1...v3.0.2) (2025-07-01)


### Bug Fixes

* Remove erroneous `pod_properties` scoping from job definition variable attribute structure ([#45](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/45)) ([7c8becf](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/7c8becf486af35d9b14aa71299bc3c8f3b4fbe85))

## [3.0.1](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v3.0.0...v3.0.1) (2025-06-27)


### Bug Fixes

* Correct launch template attribute values to match variable/API definition ([#43](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/43)) ([3a07ad9](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/3a07ad9f7cbe90011c36ba75c209a81ee1d8b1c4))

## [3.0.0](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v2.1.0...v3.0.0) (2025-06-25)


### ⚠ BREAKING CHANGES

* Upgrade AWS provider and min required Terraform version to `6.0` and `1.5.7` respectively (#38)

### Features

* Upgrade AWS provider and min required Terraform version to `6.0` and `1.5.7` respectively ([#38](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/38)) ([7781147](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/778114769cb5b1b8096ccb701fc2db3ffee83362))


### Bug Fixes

* Update CI workflow versions to latest ([#36](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/36)) ([c478369](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/c478369fdc5a73bbe334b6159fbce7e9a0937198))

## [2.1.0](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v2.0.3...v2.1.0) (2024-08-19)


### Features

* Add support for `eks_configuration` ([#32](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/32)) ([b6aa7e1](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/b6aa7e107d1da94afb6453f787bc4d8898b2063e))

## [2.0.3](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v2.0.2...v2.0.3) (2024-03-07)


### Bug Fixes

* Update CI workflow versions to remove deprecated runtime warnings ([#27](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/27)) ([64b1ba1](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/64b1ba12df6c677b682f665f9a0a3c8c9dd8c750))

### [2.0.2](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v2.0.1...v2.0.2) (2023-12-11)


### Bug Fixes

* Rename launch template parameters ([#25](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/25)) ([3e370d0](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/3e370d06bf4a7303a2bde56c0344b2e092fb6b0e))

### [2.0.1](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v2.0.0...v2.0.1) (2023-05-03)


### Bug Fixes

* Change `instance_iam_role_use_name_prefix` to use correct data type ([#20](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/20)) ([08a13f1](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/08a13f1a2d7722fb89daf16f25398c4be205f3a9))

## [2.0.0](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v1.2.3...v2.0.0) (2023-04-28)


### ⚠ BREAKING CHANGES

* Bump Terraform version to 1.0, and allow specifying compute environments for queue (#19)

### Features

* Bump Terraform version to 1.0, and allow specifying compute environments for queue ([#19](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/19)) ([8cec4e7](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/8cec4e7ed047bc20e317b007abf67f4027532dc1))

### [1.2.3](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v1.2.2...v1.2.3) (2023-04-27)


### Bug Fixes

* Add `create_before_destroy` lifecycle hook to `aws_batch_compute_environment` ([#18](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/18)) ([614fc14](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/614fc14f1be07a21a5de7a8dc0f477bf001a3519))

### [1.2.2](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v1.2.1...v1.2.2) (2023-01-24)


### Bug Fixes

* Use a version for  to avoid GitHub API rate limiting on CI workflows ([#10](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/10)) ([8205095](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/8205095e4888aea3238d4f62c9a042839ccae39b))

### [1.2.1](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v1.2.0...v1.2.1) (2022-10-27)


### Bug Fixes

* Update CI configuration files to use latest version ([#8](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/8)) ([5d739d0](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/5d739d077ad5940b140cd071f7948f0c0b5d9623))

## [1.2.0](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v1.1.2...v1.2.0) (2022-07-19)


### Features

* Add create_scheduling_policy option to job_queue ([#3](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/3)) ([86546af](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/86546af08a5791149693374e9206fb5166914b37))

### [1.1.2](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v1.1.1...v1.1.2) (2022-07-04)


### Bug Fixes

* Add default for tag lookup in job queue resources. ([#2](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/2)) ([edb1b75](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/edb1b751913f612aa9e93891976ff677a3fee4fc))

### [1.1.1](https://github.com/terraform-aws-modules/terraform-aws-batch/compare/v1.1.0...v1.1.1) (2022-04-21)


### Bug Fixes

* Update documentation to remove prior notice and deprecated workflow ([#1](https://github.com/terraform-aws-modules/terraform-aws-batch/issues/1)) ([0240a55](https://github.com/terraform-aws-modules/terraform-aws-batch/commit/0240a554cb3be716339facc3e8d6f9e3711815d0))

## [1.1.0](https://github.com/clowdhaus/terraform-aws-batch/compare/v1.0.1...v1.1.0) (2022-04-20)


### Features

* Repo has moved to [terraform-aws-modules](https://github.com/terraform-aws-modules/terraform-aws-batch) organization ([0a06907](https://github.com/clowdhaus/terraform-aws-batch/commit/0a069071da5cc744cae2fbc3b335a9c918dd6357))
