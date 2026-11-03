# Detective controls (in addition to GuardDuty).
#
# 1) IAM Access Analyzer: continuously flags resources shared outside the
#    account, such as the intentionally public backup bucket.
# 2) AWS Config managed rules: flag the intentional weaknesses (public read
#    bucket, SSH open to the internet) as NON_COMPLIANT.
#
# Cloud Labs already runs a Config recorder ("default") that records S3
# buckets and security groups, so these rules reuse it. The recorder is not
# ours to manage, so it is deliberately left out of Terraform.
#
# These detect the weaknesses the exercise requires; they do not fix them.

resource "aws_accessanalyzer_analyzer" "account" {
  analyzer_name = "wiz-lab-access-analyzer"
  type          = "ACCOUNT"
}

resource "aws_config_config_rule" "s3_public_read" {
  name = "s3-bucket-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}

resource "aws_config_config_rule" "restricted_ssh" {
  name = "restricted-ssh"
  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }
}
