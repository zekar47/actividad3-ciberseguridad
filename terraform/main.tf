terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  type        = string
  description = "Región utilizada por el proveedor de AWS."
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  type        = string
  description = "Endpoint de LocalStack para ejecutar la actividad sin una cuenta real de AWS."
  default     = "http://localhost:4566"
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3  = var.localstack_endpoint
    iam = var.localstack_endpoint
    sts = var.localstack_endpoint
  }
}

locals {
  bucket_name = "actividad3-seguro-2024"
  app_role    = "actividad3-app-role"
}

# ---------------------------------------------------------------------------
# Fase 1: bucket S3 privado, cifrado y con bloqueo total de acceso público.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "secure_bucket" {
  bucket = local.bucket_name

  tags = {
    Name        = local.bucket_name
    Environment = "academico"
    Actividad   = "3"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "secure_bucket" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "secure_bucket" {
  bucket = aws_s3_bucket.secure_bucket.id
  acl    = "private"
}

# Política explícita: sólo el rol de la aplicación puede operar sobre el bucket.
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "DenyEveryoneExceptAppRole"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.secure_bucket.arn,
      "${aws_s3_bucket.secure_bucket.arn}/*",
    ]

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = [aws_iam_role.app_role.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "secure_bucket" {
  bucket = aws_s3_bucket.secure_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

# ---------------------------------------------------------------------------
# Fase 4: rol de aplicación con política IAM restrictiva.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "app_role" {
  name               = local.app_role
  assume_role_policy = file("${path.module}/../iam/trust-policy.json")

  tags = {
    Name      = local.app_role
    Actividad = "3"
  }
}

resource "aws_iam_policy" "app_s3_read_policy" {
  name        = "actividad3-s3-read-only"
  description = "Permite leer únicamente el bucket cifrado de la actividad 3."
  policy      = file("${path.module}/../iam/app-s3-read-policy.json")
}

resource "aws_iam_role_policy_attachment" "app_s3_read_attachment" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_s3_read_policy.arn
}

# Un usuario adicional demuestra que la política NO está pensada para usuarios
# genéricos: sólo el rol anterior recibe el permiso.
resource "aws_iam_user" "auditor" {
  name = "actividad3-auditor"
}

output "bucket_name" {
  value = aws_s3_bucket.secure_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.secure_bucket.arn
}

output "app_role_arn" {
  value = aws_iam_role.app_role.arn
}

output "app_policy_arn" {
  value = aws_iam_policy.app_s3_read_policy.arn
}
