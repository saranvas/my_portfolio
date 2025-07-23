# A unique name for your S3 bucket.
variable "bucket_name" {
  description = "The name for the S3 bucket"
  type        = string
  default     = "saranvas-portfolio-site-0723-v2" # Make sure this is your unique name
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Resource 1: Create the S3 bucket
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = var.bucket_name
}

# (NEW!) Resource 2: Configure the public access block
# This tells AWS to allow public access for this bucket.
resource "aws_s3_bucket_public_access_block" "portfolio_bucket_public_access" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Resource 3: Configure the S3 bucket to host a static website
resource "aws_s3_bucket_website_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Resource 4: Create a policy to make the bucket contents public
resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.portfolio_bucket.id
  # (NEW!) This line ensures the public access block is configured before the policy is applied.
  depends_on = [aws_s3_bucket_public_access_block.portfolio_bucket_public_access]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.portfolio_bucket.arn}/*"
      }
    ]
  })
}

# Output the website URL so you know where to find it
output "website_endpoint" {
  value = "http://${aws_s3_bucket_website_configuration.portfolio_website.website_endpoint}"
}