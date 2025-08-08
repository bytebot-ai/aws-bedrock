# AWS Bedrock IRSA Role (Generic)

Creates an IAM role assumable via EKS IRSA for workloads to invoke Amazon Bedrock models.

## Features

- Trust policy restricted to a specified Kubernetes ServiceAccount via IRSA
- Least-privilege Bedrock invoke actions with optional model and region scoping
- Optional read-only access for model discovery
- Outputs for annotating your Kubernetes ServiceAccount

## Inputs

- `cluster_oidc_url` (string, required): EKS cluster OIDC issuer URL (e.g., `https://oidc.eks.<region>.amazonaws.com/id/<id>`)
- `service_account_namespace` (string, required): Namespace of the allowed ServiceAccount
- `service_account_name` (string, required): Name of the allowed ServiceAccount
- `allowed_model_ids` (list(string), optional): Bedrock foundation model IDs to allow (e.g., `anthropic.claude-3-haiku-20240307`)
- `allow_all_models` (bool, default `false`): If `true`, allow invoking all models (`Resource="*"`)
- `bedrock_regions` (list(string), required): Regions to scope permissions
- `include_read_actions` (bool, default `false`): Include `ListFoundationModels` and `GetFoundationModel`
- `role_name` (string, optional): Explicit IAM role name; default name is `bedrock-invoke-<namespace>-<name>`
- `role_max_session_duration` (number, default `3600`): Max session duration in seconds
- `tags` (map(string), optional): Resource tags
- `additional_policy_statements` (list(any), optional): Extra statements merged into the Bedrock policy

Validation enforces that either `allow_all_models = true` or `allowed_model_ids` is non-empty.

## Outputs

- `role_arn`: IAM role ARN to use in the ServiceAccount annotation
- `role_name`: IAM role name
- `service_account_annotation_key`: Always `eks.amazonaws.com/role-arn`
- `service_account_annotation_value`: Same as `role_arn`
- `assume_role_policy`: Rendered trust policy JSON (for inspection)
- `bedrock_policy`: Rendered Bedrock invoke policy JSON (for inspection)

## Kubernetes ServiceAccount Annotation

Annotate your ServiceAccount with the role ARN:

```yaml
metadata:
  annotations:
    eks.amazonaws.com/role-arn: <output role_arn>
```

## Notes

- The module derives the OIDC provider ARN from the provided `cluster_oidc_url` and the current AWS account.
- Bedrock foundation model ARNs are of the form: `arn:<partition>:bedrock:<region>::foundation-model/<model_id>`.
- Specify one or more regions in `bedrock_regions` to permit invocation.
