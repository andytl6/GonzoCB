locals {
  repo_name            = "gonzo"
  github_owner         = "ryno75"
  pipeline_name        = "testMultiSource"
  artifact_bucket      = "rksandbox-codepipeline-artifacts"
  codebuild_proj_name  = "gonzo-test"
  codedeploy_app_name  = "gonzo-test"
  codedeploy_dg_name   = "gonzo-test"
  src_action_name      = "gonzo"
  webhook_name         = "${local.pipeline_name}--Source--${local.github_owner}_${local.repo_name}"
  tnjs_repo_name       = "BeanstalkTestNodeJS"
  tnjs_src_action_name = "TestNodeJS"
  tnjs_webhook_name    = "${local.pipeline_name}--Source--${local.github_owner}_${local.tnjs_repo_name}"
}

variable "aws_profile" {
  description = "AWS Profile to deploy with"
}

variable "aws_region" {
  default     = "us-west-2"
  description = "AWS Region to deploy in"
}

variable "github_token" {
  description = "GitHub OAuth token"
}
