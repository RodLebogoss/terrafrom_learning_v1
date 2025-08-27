
provider "aws" {
  region = "eu-north-1"
}

#création du S3 bucket

resource "aws_s3_bucket" "Mask_bucket_creation" {
  #nom du bucket
  bucket = "mask-s3-bucket-tf"
  force_destroy = true
  #Empecher la suppression accidentelle du bucket
  lifecycle {
    #prevent_destroy = true # Acommenter en cas de suppression du bucket
  }
}
resource "aws_s3_bucket_versioning" "enabled_status" {
# Activer le versioning pour voir tout l’historique des révisions de vos fichiers d’état
  bucket = aws_s3_bucket.Mask_bucket_creation.id

  versioning_configuration {
    status = "Enabled"
  }
}
#Activation du chiffrement côté serveur
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.Mask_bucket_creation.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  } 
}

#Bloquer tout accès public au bucket S3

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.Mask_bucket_creation.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

#Création d’une table DynamoDB pour le verrouillage (locking)

resource "aws_dynamodb_table" "terraform_locks" {
  name = "Mask-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
