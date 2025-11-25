# S3 Bucket for Loki Chunks (log data)
resource "aws_s3_bucket" "loki_chunks" {
  bucket = "${var.project_name}-${var.environment}-loki-chunks-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-loki-chunks"
      Component   = "Loki"
      StorageType = "Chunks"
    },
    var.additional_tags
  )
}

# Enable versioning for Loki chunks bucket
resource "aws_s3_bucket_versioning" "loki_chunks" {
  bucket = aws_s3_bucket.loki_chunks.id

  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Suspended"
  }
}

# Enable encryption for Loki chunks bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "loki_chunks" {
  bucket = aws_s3_bucket.loki_chunks.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access for Loki chunks bucket
resource "aws_s3_bucket_public_access_block" "loki_chunks" {
  bucket = aws_s3_bucket.loki_chunks.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for Loki chunks
resource "aws_s3_bucket_lifecycle_configuration" "loki_chunks" {
  bucket = aws_s3_bucket.loki_chunks.id

  rule {
    id     = "loki-chunks-lifecycle"
    status = "Enabled"

    # Transition to Infrequent Access after specified days
    transition {
      days          = var.loki_chunks_ia_days
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier after specified days
    transition {
      days          = var.loki_chunks_glacier_days
      storage_class = "GLACIER"
    }

    # Expire objects after specified days (optional)
    dynamic "expiration" {
      for_each = var.loki_chunks_expiration_days > 0 ? [1] : []
      content {
        days = var.loki_chunks_expiration_days
      }
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # Clean up old versions
  dynamic "rule" {
    for_each = var.enable_s3_versioning ? [1] : []
    content {
      id     = "cleanup-old-versions"
      status = "Enabled"

      noncurrent_version_expiration {
        noncurrent_days = 30
      }
    }
  }
}

# S3 Bucket for Loki Ruler (alerting rules)
resource "aws_s3_bucket" "loki_ruler" {
  bucket = "${var.project_name}-${var.environment}-loki-ruler-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-loki-ruler"
      Component   = "Loki"
      StorageType = "Ruler"
    },
    var.additional_tags
  )
}

# Enable versioning for Loki ruler bucket
resource "aws_s3_bucket_versioning" "loki_ruler" {
  bucket = aws_s3_bucket.loki_ruler.id

  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Suspended"
  }
}

# Enable encryption for Loki ruler bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "loki_ruler" {
  bucket = aws_s3_bucket.loki_ruler.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access for Loki ruler bucket
resource "aws_s3_bucket_public_access_block" "loki_ruler" {
  bucket = aws_s3_bucket.loki_ruler.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for Loki ruler (simpler - these are config files)
resource "aws_s3_bucket_lifecycle_configuration" "loki_ruler" {
  bucket = aws_s3_bucket.loki_ruler.id

  rule {
    id     = "cleanup-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # Clean up old versions if versioning is enabled
  dynamic "rule" {
    for_each = var.enable_s3_versioning ? [1] : []
    content {
      id     = "cleanup-old-versions"
      status = "Enabled"

      noncurrent_version_expiration {
        noncurrent_days = 30
      }
    }
  }
}

# S3 Bucket for Prometheus/Mimir Long-term Storage
resource "aws_s3_bucket" "prometheus_storage" {
  bucket = "${var.project_name}-${var.environment}-prometheus-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-prometheus"
      Component   = "Prometheus"
      StorageType = "Metrics"
    },
    var.additional_tags
  )
}

# Enable versioning for Prometheus bucket
resource "aws_s3_bucket_versioning" "prometheus_storage" {
  bucket = aws_s3_bucket.prometheus_storage.id

  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Suspended"
  }
}

# Enable encryption for Prometheus bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "prometheus_storage" {
  bucket = aws_s3_bucket.prometheus_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access for Prometheus bucket
resource "aws_s3_bucket_public_access_block" "prometheus_storage" {
  bucket = aws_s3_bucket.prometheus_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for Prometheus metrics
resource "aws_s3_bucket_lifecycle_configuration" "prometheus_storage" {
  bucket = aws_s3_bucket.prometheus_storage.id

  rule {
    id     = "prometheus-metrics-lifecycle"
    status = "Enabled"

    # Transition to Infrequent Access after specified days
    transition {
      days          = var.prometheus_ia_days
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier after specified days
    transition {
      days          = var.prometheus_glacier_days
      storage_class = "GLACIER"
    }

    # Expire objects after specified days (optional)
    dynamic "expiration" {
      for_each = var.prometheus_expiration_days > 0 ? [1] : []
      content {
        days = var.prometheus_expiration_days
      }
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # Clean up old versions
  dynamic "rule" {
    for_each = var.enable_s3_versioning ? [1] : []
    content {
      id     = "cleanup-old-versions"
      status = "Enabled"

      noncurrent_version_expiration {
        noncurrent_days = 30
      }
    }
  }
}

# Optional: S3 Bucket for Tempo (distributed tracing) - for future use
resource "aws_s3_bucket" "tempo_storage" {
  bucket = "${var.project_name}-${var.environment}-tempo-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-tempo"
      Component   = "Tempo"
      StorageType = "Traces"
      Status      = "Reserved"
    },
    var.additional_tags
  )
}

# Enable encryption for Tempo bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "tempo_storage" {
  bucket = aws_s3_bucket.tempo_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access for Tempo bucket
resource "aws_s3_bucket_public_access_block" "tempo_storage" {
  bucket = aws_s3_bucket.tempo_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Basic lifecycle for Tempo (can be customized later)
resource "aws_s3_bucket_lifecycle_configuration" "tempo_storage" {
  bucket = aws_s3_bucket.tempo_storage.id

  rule {
    id     = "tempo-traces-lifecycle"
    status = "Enabled"

    # Traces are typically kept for shorter periods
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}