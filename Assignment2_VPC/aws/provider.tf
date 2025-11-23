provider "aws" {
  region = var.aws_region1
  alias  = "region1"
}
provider "aws" {
  region = var.aws_region2
  alias  = "region2"
}