# S3 Bucket Used by the Terraform State Management
# Must be initialized first prior to uncommiting the configuration for terraform
resource "aws_s3_bucket" "aws-oso-confluent" {
  bucket = "aws-oso-confluent"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Setup the S3 Bucket Policy Required by Terraform
resource "aws_s3_bucket_policy" "devsecops-bc-state-policy" {
  bucket = aws_s3_bucket.aws-oso-confluent.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": "*",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "${aws_s3_bucket.aws-oso-confluent.arn}"
    },
    {
      "Principal": "*",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": [ "${aws_s3_bucket.aws-oso-confluent.arn}/*" ]
    }
  ]
}
POLICY
}

# S3 Bucket Terraform ARN
output "aws_terraform_arn" {
  value       = aws_s3_bucket.aws-oso-confluent.arn
  description = "The ARN associated to the S3 Bucket"
}