# Genera un sufijo aleatorio para el bucket (evita duplicados en AWS)
resource "random_id" "suffix" {
  byte_length = 4
}

# 🪣 Bucket para hospedar el frontend
resource "aws_s3_bucket" "frontend" {
  bucket = "manu-frontend-website-${random_id.suffix.hex}"
}

# Configuración como sitio web estático
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Bloqueo de acceso público (se permite solo a CloudFront)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 🔒 Origin Access Control (para que CloudFront lea el bucket)
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "frontend-oac"
  description                       = "Access control for S3 frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 🌍 CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend_cdn" {
  comment             = "CDN + reverse proxy para frontend y API"
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_All"

  # ORIGEN FRONTEND (S3)
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "s3-frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  # ORIGEN BACKEND (API)
  origin {
    domain_name = "ec2-18-189-28-131.us-east-2.compute.amazonaws.com"
    origin_id   = "api-backend"

    custom_origin_config {
      http_port              = 8081
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }



  # Comportamiento principal → frontend (S3)
  default_cache_behavior {
    target_origin_id       = "s3-frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Comportamiento secundario → backend /api/*
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "api-backend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# 📜 Bucket Policy para CloudFront
resource "aws_s3_bucket_policy" "frontend_public" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontRead",
        Effect = "Allow",
        Principal = {
          "Service" : "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.frontend.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::172886169632:distribution/${aws_cloudfront_distribution.frontend_cdn.id}"
          }
        }
      }
    ]
  })
}

# 🔍 Output de URLs
output "frontend_website_url" {
  value = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.frontend_cdn.domain_name
}
