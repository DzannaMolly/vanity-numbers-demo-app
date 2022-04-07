variable "aws_region" {
  default = "us-east-1"
}

variable "account_id" {
  default = "426014231116"
}

variable "rest_api_domain_name" {
  default     = "ttecexampledomain.com"
  description = "Domain name of the API Gateway REST API for self-signed TLS certificate"
  type        = string
}

variable "rest_api_path" {
  default     = "/path1"
  description = "Path to create in the API Gateway REST API (can be used to trigger redeployments)"
  type        = string
}