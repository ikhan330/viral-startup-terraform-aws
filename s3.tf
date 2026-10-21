######################## S3 BUCKET #########################





# S3 Bucket creation for static file to be stored


resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-${var.environment}-website"
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "${path.module}/viral-startup-site-bundle/s3-static-site/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.website.id
  key          = "styles.css"
  source       = "${path.module}/viral-startup-site-bundle/s3-static-site/styles.css"
  content_type = "text/css"
}

resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.website.id
  key          = "app.js"
  source       = "${path.module}/viral-startup-site-bundle/s3-static-site/app.js"
  content_type = "application/javascript"
}

resource "aws_s3_object" "config" {
  bucket       = aws_s3_bucket.website.id
  key          = "config.js"
  source_hash = filemd5("${path.module}/viral-startup-site-bundle/s3-static-site/config.js")
  source       = "${path.module}/viral-startup-site-bundle/s3-static-site/config.js"
  content_type = "application/javascript"
}

# S3 bucket ko public access se protect karna
resource "aws_s3_bucket_public_access_block" "website" {
  # Hamari existing website bucket
  bucket = aws_s3_bucket.website.id

  # Public ACLs ko block karna
  block_public_acls = true

  # Public bucket policies ko block karna
  block_public_policy = true

  # Public ACLs ko ignore karna
  ignore_public_acls = true

  # Public bucket access ko restrict karna
  restrict_public_buckets = true
}