provider "aws" {
  region = var.aws_region
}

# 1. Il Bucket S3 per salvare i file tfstate
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-tf-state-${var.environment}"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Store"
    Environment = var.environment
  }
}

# Abilita il versioning
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Crittografia lato server
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Blocca accesso pubblico bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. Tabella DynamoDB per il Locking 
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.environment
  }
}

# Definisce GitHub come provider OIDC

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  
  # Serve per la CA di GitHub.
  # È pubblico e standard per GitHub Actions, copiato così come è.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Data source per generare la Trust Policy in modo pulito
data "aws_iam_policy_document" "github_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Limita l'accesso solo ai miei repository
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:PartySlayer/*"] 
    }
  }
}

# Creazione del Ruolo IAM
resource "aws_iam_role" "github_actions_role" {
  name               = "GitHubActionsDeployRole"
  assume_role_policy = data.aws_iam_policy_document.github_trust_policy.json
}

# Per la demo admin policy, in prod ridurrei al minimo i permessi
resource "aws_iam_role_policy_attachment" "github_admin" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_role_arn" {
  value = aws_iam_role.github_actions_role.arn
  description = "L'ARN da incollare nel file YAML della GitHub Action"
}
