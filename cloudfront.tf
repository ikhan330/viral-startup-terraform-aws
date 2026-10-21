resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-cloudfront-oac"
  description                       = "OAC for s3 bucket CDN"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}








# CloudFront distribution website ko visitors tak deliver karegi

resource "aws_cloudfront_distribution" "cloudfront-distribution" {

  # Hamari existing S3 bucket ko origin banana
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "s3-website"

    # Pehle banaye hue OAC ko S3 origin se connect karna
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Distribution ko enable karna
  enabled = true

  # Website ka main page
  default_root_object = "index.html"

  # Website ki files ke liye cache settings
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-website"

    # HTTP requests ko HTTPS par redirect karna
    viewer_protocol_policy = "redirect-to-https"

    # AWS ki managed caching policy use karna
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # HTTPS certificate use karna
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Filhaal sabhi locations ke visitors ko allow karna
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Kam cost wala CloudFront price class
  price_class = "PriceClass_100"
}


# CloudFront ko private S3 bucket ki files read karne ki permission
resource "aws_s3_bucket_policy" "website" {

  # Hamari existing S3 bucket
  bucket = aws_s3_bucket.website.id

  # S3 access policy
  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowCloudFrontRead"
        Effect = "Allow"

        # Sirf CloudFront service ko permission
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        # Sirf files read karne ki permission
        Action = "s3:GetObject"

        # Bucket ke andar ki sabhi files
        Resource = "${aws_s3_bucket.website.arn}/*"

        # Sirf hamari CloudFront distribution ko allow karna
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cloudfront-distribution.arn
          }
        }
      }
    ]
  })
}