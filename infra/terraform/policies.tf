data "aws_iam_policy_document" "codebuild_arpdoc" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals = {
      type = "Service"

      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codedeploy_arpdoc" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals = {
      type = "Service"

      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_arpdoc" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals = {
      type = "Service"

      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_access" {
  statement {
    sid = "S3FullAccess"

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${local.artifact_bucket}",
      "arn:aws:s3:::${local.artifact_bucket}/*",
    ]
  }

  statement {
    sid = "EC2ReadAccess"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    sid = "CloudWatchLogsWriteAccess"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "codedeploy_access" {
  statement {
    sid = "CodeDeployAccess"

    actions = [
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:DeleteLifecycleHook",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLifecycleHooks",
      "autoscaling:PutLifecycleHook",
      "autoscaling:RecordLifecycleActionHeartbeat",
      "codedeploy:*",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "tag:GetTags",
      "tag:GetResources",
      "sns:Publish",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "codepipeline_access" {
  statement {
    sid = "S3ReadAccess"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
    ]

    resources = ["*"]
  }

  statement {
    sid = "S3PutObjectAccess"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::codepipeline*",
      "arn:aws:s3:::elasticbeanstalk*",
    ]
  }

  statement {
    sid = "CodeBuildAccess"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }

  statement {
    sid = "CodeDeployAccess"

    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision",
    ]

    resources = ["*"]
  }

  statement {
    sid = "MiscServiceAccess"

    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
      "iam:PassRole",
    ]

    resources = ["*"]
  }
}
