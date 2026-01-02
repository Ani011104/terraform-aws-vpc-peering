terraform {
  backend "s3" {
    bucket       = "terraform-aws-backend-bucket-anirudh"
    region       = "ap-south-1"
    key          = "dev/day15/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
