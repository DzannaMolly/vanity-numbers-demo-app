terraform {
  backend "s3" {
    bucket = "scf-tf-remote-demo"
    key    = "state-ttec/terraform.tfstate"
    region = "us-east-1"
  }
}

