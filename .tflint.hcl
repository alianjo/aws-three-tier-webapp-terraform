config {
  format = "compact"
}

plugin "aws" {
  enabled = true
  version = "0.32.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_instance_invalid_type" {
  enabled = true
}
