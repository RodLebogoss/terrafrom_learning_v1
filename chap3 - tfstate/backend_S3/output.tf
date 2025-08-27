output "s3_bucket_arn" {
  description = "ARN bucket S3"
  value = aws_s3_bucket.Mask_bucket_creation.arn
}

output "dynamodb_table" {
  description = "Dynamo db table"
  value = aws_dynamodb_table.terraform_locks.name
  
}