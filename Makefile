SHELL := /usr/bin/env bash
TF_DIR ?= infra
ENV ?= dev
TF_VARS ?= $(TF_DIR)/envs/$(ENV)/terraform.tfvars
TF_BACKEND ?= $(TF_DIR)/envs/$(ENV)/backend.hcl

export AWS_REGION ?= us-east-1

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

.PHONY: init
init: ## Initialise Terraform with environment backend configuration
	cd $(TF_DIR) && terraform init -backend-config=$(TF_BACKEND)

.PHONY: fmt
fmt: ## Format Terraform code
	cd $(TF_DIR) && terraform fmt -recursive

.PHONY: validate
validate: ## Validate Terraform configuration
	cd $(TF_DIR) && terraform validate

.PHONY: plan
plan: ## Generate Terraform plan
	cd $(TF_DIR) && terraform plan -var-file=$(TF_VARS)

.PHONY: apply
apply: ## Apply Terraform changes
	cd $(TF_DIR) && terraform apply -var-file=$(TF_VARS) -auto-approve

.PHONY: destroy
destroy: ## Destroy Terraform resources
	cd $(TF_DIR) && terraform destroy -var-file=$(TF_VARS) -auto-approve

.PHONY: pre-commit
pre-commit: ## Run all pre-commit hooks locally
	pre-commit run --all-files

.PHONY: app-build
app-build: ## Build the application Docker image
	cd app && docker build -t three-tier-webapp:latest .

.PHONY: app-test
app-test: ## Run basic Node.js tests
	cd app && npm test

.PHONY: web-preview
web-preview: ## Open the static web front-end locally
	python3 -m http.server --directory web 8080
