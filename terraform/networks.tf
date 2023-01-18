// Not creating any VPCs or subnets but obtaining references
// to them so that we can use them elsewhere.

resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_subnet_a" {
    availability_zone = "us-east-1a"
}
resource "aws_default_subnet" "default_subnet_b" {
    availability_zone = "us-east-1b"
}
resource "aws_default_subnet" "default_subnet_c" {
    availability_zone = "us-east-1c"
}