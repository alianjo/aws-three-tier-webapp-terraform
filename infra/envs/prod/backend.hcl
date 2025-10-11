bucket         = "three-tier-webapp-prod-tf-state"
key            = "terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "three-tier-webapp-prod-tf-locks"
encrypt        = true
