# Preventative control: stop anyone -- including this lab account's own
# admin-equivalent user -- from disabling or deleting the audit trail
# built in github_oidc.tf / the CloudTrail setup. An explicit Deny always
# wins over an Allow in IAM's evaluation logic, regardless of what other
# broad permissions the principal holds.

variable "preventative_control_iam_user" {
  description = "IAM user to attach the deny-trail-tampering preventative control to (the Cloud Labs session user, from `aws sts get-caller-identity`)"
  type        = string
  default     = "odl_user_2450046"
}

resource "aws_iam_user_policy" "deny_trail_tamper" {
  name = "deny-trail-tamper"
  user = var.preventative_control_iam_user

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyAuditTampering"
      Effect = "Deny"
      Action = [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "cloudtrail:UpdateTrail"
      ]
      Resource = "*"
    }]
  })
}
