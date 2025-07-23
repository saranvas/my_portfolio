# A unique name for your S3 bucket.
# IMPORTANT: S3 bucket names must be globally unique. Change "your-unique-name-12345" to something unique!
variable "bucket_name" {
  description = "The name for the S3 bucket"
  type        = string
  default     = "your-unique-name-12345-portfolio-site" 
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # You can choose a different region if you like
}

# Resource 1: Create the S3 bucket
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = var.bucket_name
}

# Resource 2: Configure the S3 bucket to host a static website
resource "aws_s3_bucket_website_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Resource 3: Create a policy to make the bucket contents public (so people can see your site)
resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.portfolio_bucket.id
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