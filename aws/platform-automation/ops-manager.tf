resource "aws_eip" "ops-manager" {
  domain = "vpc"
}

resource "tls_private_key" "ops-manager" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "ops-manager" {
  key_name   = "${var.environment_name}-ops-manager-key"
  public_key = tls_private_key.ops-manager.public_key_openssh
}

data "aws_iam_policy_document" "ops-manager" {
  statement {
    sid       = "AllowToGetInfoAboutCurrentInstanceProfile"
    effect    = "Allow"
    actions   = ["iam:GetInstanceProfile"]
    resources = [aws_iam_instance_profile.ops-manager.arn]
  }

  statement {
    sid     = "AllowToCreateInstanceWithCurrentInstanceProfile"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      aws_iam_role.ops-manager.arn
    ]
  }

  statement {
    sid    = "NotAllowRules"
    effect = "Deny"
    actions = [
      "iam:Add*",
      "iam:Attach*",
      "iam:ChangePassword",
      "iam:Create*",
      "iam:DeactivateMFADevice",
      "iam:Delete*",
      "iam:Detach*",
      "iam:EnableMFADevice",
      "iam:GenerateCredentialReport",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:GetAccessKeyLastUsed",
      "iam:GetAccountAuthorizationDetails",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:GetContextKeysForCustomPolicy",
      "iam:GetContextKeysForPrincipalPolicy",
      "iam:GetCredentialReport",
      "iam:GetGroup",
      "iam:GetGroupPolicy",
      "iam:GetLoginProfile",
      "iam:GetOpenIDConnectProvider",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:GetSAMLProvider",
      "iam:GetSSHPublicKey",
      "iam:GetServerCertificate",
      "iam:GetServiceLastAccessedDetails",
      "iam:GetUser",
      "iam:GetUserPolicy",
      "iam:List*",
      "iam:Put*",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:RemoveUserFromGroup",
      "iam:ResyncMFADevice",
      "iam:SetDefaultPolicyVersion",
      "iam:SimulateCustomPolicy",
      "iam:SimulatePrincipalPolicy",
      "iam:Update*"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "OpsMgrInfrastructureIaasConfiguration"
    effect  = "Allow"
    actions = [
      "ec2:DescribeKeypairs",
      "ec2:DescribeVpcs",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeSubnets"
    ]
    resources = ["*"]
  }


  statement {
    sid     = "OpsMgrS3Permissions"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid     = "OpsMgrRDSPermissions"
    effect  = "Allow"
    actions = ["rds:*"]
    resources = [
      "arn:aws:rds:*:*:*"
    ]
  }
  
  statement {
    sid    = "OpsMgrEC2Permissions"
    effect = "Allow"
    actions = [
      "ec2:DescribeKeypairs",
      "ec2:DescribeVpcs",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeImages",
      "ec2:DeregisterImage",
      "ec2:DescribeSubnets",
      "ec2:RunInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:DescribeInstances",
      "ec2:TerminateInstances",
      "ec2:RebootInstances",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "ec2:DescribeAddresses",
      "ec2:DisassociateAddress",
      "ec2:AssociateAddress",
      "ec2:CreateTags",
      "ec2:DescribeVolumes",
      "ec2:CreateVolume",
      "ec2:AttachVolume",
      "ec2:DeleteVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:DescribeSnapshots",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "RequiredIfUsingHeavyStemcells"
    effect  = "Allow"
    actions = [
      "ec2:RegisterImage",
      "ec2:DeregisterImage"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "RequiredIfEncryptingStemcells"
    effect  = "Allow"
    actions = [
      "ec2:CopyImage"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "RequiredIfUsingCustomKMSKeys"
    effect  = "Allow"
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey*",
      "kms:Decrypt*"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "RequiredIfUsingSpotBidPriceCloudProperties"
    effect  = "Allow"
    actions = [
      "ec2:CancelSpotInstanceRequests",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:RequestSpotInstances"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ASMListPermissions"
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ASMGetPermissions"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      "arn:aws:secretsmanager:*:*:secret:/concourse/*",
      "arn:aws:secretsmanager:*:*:secret:__concourse-health-check-??????",
    ]
  }
}


resource "aws_iam_policy" "ops-manager-role" {
  name   = "${var.environment_name}-ops-manager-role"
  policy = data.aws_iam_policy_document.ops-manager.json
}


data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# when auth with AWS Instance Profile

resource "aws_iam_role" "ops-manager" {
  name = "${var.environment_name}-ops-manager-role"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}

resource "aws_iam_instance_profile" "ops-manager" {
  name = "${var.environment_name}-ops-manager"
  role = aws_iam_role.ops-manager.name

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_role_policy_attachment" "ops-manager-policy" {
  role       = aws_iam_role.ops-manager.name
  policy_arn = aws_iam_policy.ops-manager-role.arn
}


# when auth with AWS Keys (access key and secret key)

# comment out because lab AWS svc account is not able to create IAM user
#resource "aws_iam_user" "ops-manager" {
#  force_destroy = true
#  name          = "${var.environment_name}-ops-manager"
#}
#
#resource "aws_iam_access_key" "ops-manager" {
#  user = aws_iam_user.ops-manager.name
#}
#
#resource "aws_iam_user_policy" "ops-manager" {
#  name   = "${var.environment_name}-ops-manager-policy"
#  user   = aws_iam_user.ops-manager.name
#  policy = data.aws_iam_policy_document.ops-manager.json
#}
