data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume" {
  statement {
    sid     = "EksOidcAssumeRole"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_oidc_url, "https://", "")}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
      ]
    }
  }
}

resource "aws_iam_role" "bedrock_invoke" {
  name                 = var.role_name != null ? var.role_name : "bedrock-invoke-${var.service_account_namespace}-${var.service_account_name}"
  assume_role_policy   = data.aws_iam_policy_document.assume.json
  max_session_duration = var.role_max_session_duration
  tags                 = var.tags
}

data "aws_iam_policy_document" "bedrock_base" {
  statement {
    sid = "BedrockInvoke"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = var.allow_all_models ? ["*"] : flatten([
      for r in var.bedrock_regions : [
        for id in var.allowed_model_ids : "arn:${data.aws_partition.current.partition}:bedrock:${r}::foundation-model/${id}"
      ]
    ])
  }

  dynamic "statement" {
    for_each = var.include_read_actions ? [1] : []
    content {
      sid = "BedrockRead"
      actions = [
        "bedrock:ListFoundationModels",
        "bedrock:GetFoundationModel"
      ]
      resources = ["*"]
    }
  }
}

data "aws_iam_policy_document" "bedrock" {
  source_policy_documents = [data.aws_iam_policy_document.bedrock_base.json]
  override_policy_documents = length(var.additional_policy_statements) > 0 ? [
    jsonencode({ Statement = var.additional_policy_statements })
  ] : []
}

resource "aws_iam_role_policy" "bedrock_invoke" {
  name   = "bedrock-invoke"
  role   = aws_iam_role.bedrock_invoke.id
  policy = data.aws_iam_policy_document.bedrock.json
}
