## EC2 instancs SSH key

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.environment_name}-ec2-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

## IAM

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
      aws_iam_role.ops-manager.arn,
      aws_iam_role.tas-blobstore.arn
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
      "kms:DescribeKey*"
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

resource "aws_iam_policy" "ops-manager" {
  name   = "${var.environment_name}-ops-manager-policy"
  policy = data.aws_iam_policy_document.ops-manager.json
}



# Instance Profile to configure in Ops Manager

resource "aws_iam_role" "ops-manager" {
  name = "${var.environment_name}-ops-manager-role"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ops-manager" {
  role       = aws_iam_role.ops-manager.name
  policy_arn = aws_iam_policy.ops-manager.arn
}

resource "aws_iam_instance_profile" "ops-manager" {
  name = "${var.environment_name}-ops-manager"
  role = aws_iam_role.ops-manager.name

  lifecycle {
    ignore_changes = [name]
  }
}



# IAM user Access Keys (access key and secret key) to configure in Ops Manager

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
#  name   = "${var.environment_name}-ops-manager-user-policy"
#  user   = aws_iam_user.ops-manager.name
#  policy = data.aws_iam_policy_document.ops-manager.json
#}


# Instance Profile to configure for TAS components
#   https://docs.vmware.com/en/VMware-Tanzu-Application-Service/5.0/tas-for-vms/pas-file-storage.html

data "aws_iam_policy_document" "tas-blobstore" {
  statement {
    sid     = "TasBlobstorePolicy"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.buckets["buildpacks"].arn,
      "${aws_s3_bucket.buckets["buildpacks"].arn}/*",
      aws_s3_bucket.buckets["packages"].arn,
      "${aws_s3_bucket.buckets["packages"].arn}/*",
      aws_s3_bucket.buckets["resources"].arn,
      "${aws_s3_bucket.buckets["resources"].arn}/*",
      aws_s3_bucket.buckets["droplets"].arn,
      "${aws_s3_bucket.buckets["droplets"].arn}/*"
    ]
  }
}

resource "aws_iam_policy" "tas-blobstore" {
  name   = "${var.environment_name}-tas-blobstore-policy"
  policy = data.aws_iam_policy_document.tas-blobstore.json
}

resource "aws_iam_role" "tas-blobstore" {
  name = "${var.environment_name}-tas-blobstore-role"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "tas-blobstore" {
  role       = aws_iam_role.tas-blobstore.name
  policy_arn = aws_iam_policy.tas-blobstore.arn
}

resource "aws_iam_instance_profile" "tas-blobstore" {
  name = "${var.environment_name}-tas-blobstore"
  role = aws_iam_role.tas-blobstore.name

  lifecycle {
    ignore_changes = [name]
  }
}
