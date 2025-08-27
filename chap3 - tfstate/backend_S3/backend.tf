terraform {
  backend "s3" {
    bucket = "mask-s3-bucket-tf"
    region = "eu-north-1"
    dynamodb_table = "Mask-terraform-lock"
    encrypt        = true
    key    = "global/s3/terraform.tfstate"
  }
}
