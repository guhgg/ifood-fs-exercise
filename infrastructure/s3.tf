resource "aws_s3_bucket" "fs-s3"{
    bucket = "fs-landing-zone"
    acl    = "private"
    
    versioning {
        enabled = false
    }

    server_side_encryption_configuration {
      rule {
          apply_server_side_encryption_by_default {
              sse_algorithm = "aws:kms"
          }
      }
    }

    force_destroy = true

    tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "fs-s3" {
    bucket                  = aws_s3_bucket.fs-s3.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}