terraform {
  backend "s3" {
    bucket = "scf-tf-remote-demo"
    key    = "state-ttec/terraform.tfstate"
    region = var.aws_region
  }
}

