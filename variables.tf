variable "cluster_oidc_url" {
  description = "EKS cluster OIDC issuer URL (e.g., https://oidc.eks.<region>.amazonaws.com/id/<id>)"
  type        = string
}

variable "service_account_namespace" {
  description = "Kubernetes namespace of the service account allowed to assume this role"
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name allowed to assume this role"
  type        = string
}

variable "allowed_model_ids" {
  description = "List of Bedrock foundation model IDs to allow (e.g., anthropic.claude-3-haiku-20240307)"
  type        = list(string)
  default     = []
}

variable "allow_all_models" {
  description = "If true, allow invoking all Bedrock models (Resource='*')"
  type        = bool
  default     = false

  validation {
    condition     = var.allow_all_models || length(var.allowed_model_ids) > 0
    error_message = "Either set allow_all_models = true or provide at least one allowed_model_ids entry."
  }
}

variable "bedrock_regions" {
  description = "Regions to scope Bedrock invoke permissions to."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.bedrock_regions) > 0
    error_message = "Provide at least one region in bedrock_regions."
  }
}

variable "include_read_actions" {
  description = "Include read-only Bedrock actions like ListFoundationModels."
  type        = bool
  default     = false
}

variable "role_name" {
  description = "Explicit IAM role name. If unset, name_prefix is used."
  type        = string
  default     = null
}


variable "role_max_session_duration" {
  description = "Max session duration for the role in seconds."
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Tags to apply to created resources."
  type        = map(string)
  default     = {}
}

variable "additional_policy_statements" {
  description = "Additional IAM policy statements to merge into the generated Bedrock policy (JSON objects)."
  type        = list(any)
  default     = []
}
