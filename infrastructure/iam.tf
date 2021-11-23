data "aws_iam_policy_document" "task_assume" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        } 
    }
} 

data "aws_iam_policy_document" "emr_assume" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["elasticmapreduce.amazonaws.com"]
        } 
    }
}

data "aws_iam_policy_document" "ec2_assume" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        } 
    }
}

data "aws_iam_policy_document" "cloudwatch_events_assume" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["events.amazon.com"]
        }
    }
}


data "aws_iam_policy_document" "task_permissions" {
    statement {
        effect = "Allow"
        resources = [
            aws_cloudwatch_log_group.fs-cloudwatch.arn
        ]
        actions = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
        ]
    }

    statement {
        effect = "Allow"
        resources = [
            "*"
        ]
        actions = [
            "s3:ListAllMyBuckets",
            "logs:PutLogEvents"
        ]
    }
    
    statement {
        effect    = "Allow"
        resources = ["*"]
        actions   = [
            "s3:ListBucket", 
            "s3:ListAllMyBuckets", 
            "s3:PutObject", 
            "s3:GetObject", 
            "s3:DeleteObject",
            "s3:GetBucketLocation",
            "s3:AbortMultipartUpload",
            "s3:ListMultipartUpload",
            "s3:ListMultipartUploadParts",
            "s3:ListBucketMultipartUploads"]
    }

    statement {
        effect    = "Allow"
        resources = [aws_dynamodb_table.fs-dynamodb-utils-table.arn]
        actions    = ["dynamodb:GetItem"]
    }

}

data "aws_iam_policy_document" "task_execution_permissions" {
    statement {
        effect = "Allow"
        resources = [
            "*",
        ]
        actions = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
        ]
    }
}

data "aws_iam_policy_document" "emr_service_permissions" {
    statement {
        effect = "Allow"
        resources = [
            "*",
        ]
        actions = [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:DescribeInstances",
            "glue:GetTableVersions",
            "glue:GetPartitions",
            "cloudwatch:DeleteAlarms",
            "sqs:ReceiveMessage",
            "s3:Get*",
            "sqs:GetQueue*",
            "s3:List*",
            "ec2:DescribeVolumeStatus",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:DescribeVolumes",
            "ec2:DescribeKeyPairs",
            "iam:ListRolePolicies",
            "iam:GetRole",
            "ec2:CreateTags",
            "ec2:RunInstances",
            "glue:UpdateSchema",
            "application-autoscaling:DeleteScalingPolicy",
            "ec2:CreateNetworkInterface",
            "ec2:CancelSpotInstanceRequests",
            "glue:GetPartition",
            "sqs:PurgeQueue",
            "cloudwatch:DescribeAlarms",
            "ec2:DescribeSubnets",
            "iam:GetRolePolicy",
            "glue:ListSchemaVersions",
            "glue:CreateRegistry",
            "glue:DeleteTableVersion",
            "ec2:DescribeVpcEndpointServices",
            "ec2:DescribeSpotInstanceRequests",
            "ec2:ModifyImageAttribute",
            "ec2:DescribeVpcAttribute",
            "glue:CreateJob",
            "iam:PassRole",
            "glue:GetTableVersion",
            "ec2:DescribeAvailabilityZones",
            "glue:ListSchemas",
            "glue:CreatePartition",
            "glue:UpdatePartition",
            "ec2:DescribeInstanceStatus",
            "glue:RegisterSchemaVersion",
            "glue:GetRegistry",
            "ec2:DeleteLaunchTemplate",
            "glue:GetTags",
            "ec2:DescribeSecurityGroups",
            "glue:GetTable",
            "glue:GetDatabase",
            "ec2:CreateLaunchTemplate",
            "glue:CreateDatabase",
            "ec2:DescribeVpcs",
            "glue:DeleteSchemaVersions",
            "glue:SearchTables",
            "glue:BatchCreatePartition",
            "glue:UpdateTable",
            "s3:CreateBucket",
            "glue:DeleteTable",
            "glue:GetSchema",
            "ec2:DeleteVolume",
            "glue:DeleteSchema",
            "sqs:Delete*",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeNetworkAcls",
            "ec2:DescribeRouteTables",
            "glue:TagResource",
            "glue:GetSchemaByDefinition",
            "sdb:BatchPutAttributes",
            "ec2:DetachVolume",
            "glue:UpdateDatabase",
            "application-autoscaling:RegisterScalableTarget",
            "glue:CreateTable",
            "glue:GetTables",
            "ec2:DescribeLaunchTemplates",
            "ec2:DeleteNetworkInterface",
            "ec2:CreateFleet",
            "ec2:DescribePrefixLists",
            "glue:CreateConnection",
            "glue:BatchGetJobs",
            "glue:CreateSchema",
            "application-autoscaling:PutScalingPolicy",
            "glue:BatchDeleteTable",
            "glue:UpdateClassifier",
            "ec2:DescribeVpcEndpoints",
            "glue:DeletePartition",
            "glue:GetWorkflow",
            "glue:DeleteDatabase",
            "ec2:RequestSpotInstances",
            "ec2:DeleteTags",
            "glue:RemoveSchemaVersionMetadata",
            "ec2:DescribeDhcpOptions",
            "glue:DeleteRegistry",
            "ec2:DescribeSpotPriceHistory",
            "glue:PutDataCatalogEncryptionSettings",
            "ec2:DescribeNetworkInterfaces",
            "glue:UpdateRegistry",
            "ec2:CreateSecurityGroup",
            "glue:UntagResource",
            "ec2:ModifyInstanceAttribute",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:TerminateInstances",
            "ec2:DetachNetworkInterface",
            "application-autoscaling:Describe*",
            "ec2:DescribeTags",
            "glue:GetDatabases",
            "iam:ListInstanceProfiles",
            "ec2:DescribeImages",
            "glue:PutSchemaVersionMetadata",
            "cloudwatch:PutMetricAlarm",
            "glue:UpdateConnection",
            "glue:GetSchemaVersion",
            "ec2:DeleteSecurityGroup",
            "sqs:CreateQueue",
            "sdb:Select",
            "application-autoscaling:DeregisterScalableTarget"
        ]
    }
}

resource "aws_iam_role" "task_role" {
    name               = "fs-task-role"
    assume_role_policy = data.aws_iam_policy_document.task_assume.json
    tags               = local.common_tags
}

resource "aws_iam_role" "execution_role" {
    name               = "fs-execution-role"
    assume_role_policy = data.aws_iam_policy_document.task_assume.json
    tags               = local.common_tags
}

resource "aws_iam_role" "emr_role" {
    name               = "fs-emr_role"
    assume_role_policy = data.aws_iam_policy_document.emr_assume.json
    tags               = local.common_tags
}

resource "aws_iam_role" "ec2_role" {
    name               = "fs-ec2_role"
    assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
    tags               = local.common_tags
}

resource "aws_iam_role_policy" "emr_execution" {
    name   = "fs-emr-execution"
    role   = aws_iam_role.emr_role.id
    policy = data.aws_iam_policy_document.emr_service_permissions.json
}

resource "aws_iam_role_policy" "task_execution" {
    name   = "fs-task-execution"
    role   = aws_iam_role.execution_role.id
    policy = data.aws_iam_policy_document.task_execution_permissions.json
}

resource "aws_iam_role_policy" "log_role" {
    name   = "fs-log-role"
    role   = aws_iam_role.task_role.id
    policy = data.aws_iam_policy_document.task_permissions.json
}

resource "aws_iam_instance_profile" "fs-emr" {
  name = "fs-emr"
  role = aws_iam_role.emr_role.name
}