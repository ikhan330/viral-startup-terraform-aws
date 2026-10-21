
variable "cloudfront_distribution_id" {
  description = "Existing CloudFront distribution ID"
  type        = string
}

resource "terraform_data" "config_invalidation" {
  triggers_replace = [
    filemd5("${path.module}/viral-startup-site-bundle/s3-static-site/config.js")
  ]

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${var.cloudfront_distribution_id} --paths /config.js"
  }
}
