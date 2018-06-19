provider "aws" {
  version = "1.20.0"
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

data "aws_caller_identity" "current" {}

#
# CodeBuild Resources
#
resource "aws_iam_role" "codebuild" {
  name               = "codebuild_service"
  path               = "/gonzo/"
  assume_role_policy = "${data.aws_iam_policy_document.codebuild_arpdoc.json}"
}

resource "aws_iam_role_policy" "codebuild" {
  name   = "codebuild_service_policy"
  role   = "${aws_iam_role.codebuild.id}"
  policy = "${data.aws_iam_policy_document.codebuild_access.json}"
}

resource "aws_codebuild_project" "gonzo_test" {
  name           = "${local.codebuild_proj_name}"
  description    = "gonzo_test_codebuild_project"
  build_timeout  = "5"
  service_role   = "${aws_iam_role.codebuild.arn}"
  encryption_key = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"

  artifacts {
    type = "CODEPIPELINE"
    name = "gonzo-bld"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/golang:1.10"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      "name"  = "PROJECT_NAME"
      "value" = "gonzo"
    }
  }

  source {
    type = "CODEPIPELINE"
  }
}

#
# CodeDeploy Resources
#
resource "aws_iam_role" "codedeploy" {
  name               = "codedeploy_service"
  path               = "/gonzo/"
  assume_role_policy = "${data.aws_iam_policy_document.codedeploy_arpdoc.json}"
}

resource "aws_iam_role_policy" "codedeploy" {
  name   = "codedeploy_service_policy"
  role   = "${aws_iam_role.codedeploy.id}"
  policy = "${data.aws_iam_policy_document.codedeploy_access.json}"
}

resource "aws_codedeploy_app" "gonzo_test" {
  name = "${local.codedeploy_app_name}"
}

resource "aws_codedeploy_deployment_group" "gonzo_test" {
  app_name               = "${aws_codedeploy_app.gonzo_test.name}"
  deployment_group_name  = "${local.codedeploy_dg_name}"
  service_role_arn       = "${aws_iam_role.codedeploy.arn}"
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      type  = "KEY_AND_VALUE"
      key   = "Name"
      value = "gonzo"
    }
  }

  ec2_tag_set {
    ec2_tag_filter {
      type  = "KEY_AND_VALUE"
      key   = "Environment"
      value = "test"
    }
  }

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

#
# CodePipeline Resources
#
resource "aws_s3_bucket" "code_artifacts" {
  bucket = "${local.artifact_bucket}"
}

resource "aws_iam_role" "codepipeline" {
  name               = "codepipeline_service"
  path               = "/gonzo/"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_arpdoc.json}"
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "codepipeline_service_policy"
  role   = "${aws_iam_role.codepipeline.id}"
  policy = "${data.aws_iam_policy_document.codepipeline_access.json}"
}

data "template_file" "gonzo_webhook_json" {
  template = "${file("data/webhook.json.tpl")}"

  vars {
    webhook_name  = "${local.webhook_name}"
    pipeline_name = "${local.pipeline_name}"
    target_action = "${local.src_action_name}"
    token         = "${var.github_token}"
  }
}

data "template_file" "testNodeJS_webhook_json" {
  template = "${file("data/webhook.json.tpl")}"

  vars {
    webhook_name  = "${local.tnjs_webhook_name}"
    pipeline_name = "${local.pipeline_name}"
    target_action = "${local.tnjs_src_action_name}"
    token         = "${var.github_token}"
  }
}

resource "aws_codepipeline" "test_multi_source" {
  name     = "${local.pipeline_name}"
  role_arn = "${aws_iam_role.codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.code_artifacts.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "${local.src_action_name}"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      output_artifacts = ["gonzo-src"]
      version          = "1"

      configuration {
        Owner                = "${local.github_owner}"
        Repo                 = "${local.repo_name}"
        Branch               = "master"
        OAuthToken           = "${var.github_token}"
        PollForSourceChanges = "false"
      }
    }

    action {
      name             = "${local.tnjs_src_action_name}"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      output_artifacts = ["testNodeJS-src"]
      version          = "1"

      configuration {
        Owner                = "2ndWatch"
        Repo                 = "${local.tnjs_repo_name}"
        Branch               = "master"
        OAuthToken           = "${var.github_token}"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "gonzo"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["gonzo-src"]
      output_artifacts = ["gonzo-bld"]
      version          = "1"

      configuration {
        ProjectName = "${local.codebuild_proj_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "gonzo"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["gonzo-bld"]
      version         = "1"

      configuration {
        ApplicationName     = "${aws_codedeploy_deployment_group.gonzo_test.app_name}"
        DeploymentGroupName = "${aws_codedeploy_deployment_group.gonzo_test.deployment_group_name}"
      }
    }

    action {
      name            = "testNodeJS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["testNodeJS-src"]
      version         = "1"

      configuration {
        ApplicationName = "testNodeJS"
        EnvironmentName = "Testnodejs-env"
      }
    }
  }

  # ATTENTION:
  # The following provisioners require the AWS CLI to be installed
  # and configured with the same profile being used for Terraform
  provisioner "local-exec" {
    command = "aws codepipeline put-webhook --cli-input-json '${data.template_file.gonzo_webhook_json.rendered}'"

    environment {
      AWS_DEFAULT_PROFILE = "${var.aws_profile}"
      AWS_DEFAULT_REGION  = "${var.aws_region}"
    }
  }

  provisioner "local-exec" {
    command = "aws codepipeline register-webhook-with-third-party --webhook-name ${local.webhook_name}"

    environment {
      AWS_DEFAULT_PROFILE = "${var.aws_profile}"
      AWS_DEFAULT_REGION  = "${var.aws_region}"
    }
  }

  provisioner "local-exec" {
    command = "aws codepipeline put-webhook --cli-input-json '${data.template_file.testNodeJS_webhook_json.rendered}'"

    environment {
      AWS_DEFAULT_PROFILE = "${var.aws_profile}"
      AWS_DEFAULT_REGION  = "${var.aws_region}"
    }
  }

  provisioner "local-exec" {
    command = "aws codepipeline register-webhook-with-third-party --webhook-name ${local.tnjs_webhook_name}"

    environment {
      AWS_DEFAULT_PROFILE = "${var.aws_profile}"
      AWS_DEFAULT_REGION  = "${var.aws_region}"
    }
  }
}
