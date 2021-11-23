data "aws_region" "current_region" {}

resource "aws_vpc" "fs-vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"
    enable_dns_support   = "true"
    tags                 = local.common_tags
}

resource "aws_internet_gateway" "fs-internet-gateway" {
    vpc_id = local.vpc_id
    tags   = local.common_tags
}

resource "aws_route" "fs-route" {
    depends_on                = [aws_vpc.fs-vpc]
    route_table_id            = aws_vpc.fs-vpc.default_route_table_id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id                = aws_internet_gateway.fs-internet-gateway.id

}

resource "aws_subnet" "fs-private-subnet-a" {
    vpc_id                  = aws_vpc.fs-vpc.id
    availability_zone       = "${data.aws_region.current_region.name}a"
    cidr_block              = cidrsubnet(aws_vpc.fs-vpc.cidr_block, 4, 0)
    tags                    = local.common_tags
}

resource "aws_subnet" "fs-private-subnet-b" {
    vpc_id                  = aws_vpc.fs-vpc.id
    availability_zone       = "${data.aws_region.current_region.name}b"
    cidr_block              = cidrsubnet(aws_vpc.fs-vpc.cidr_block, 4, 1)
    tags                    = local.common_tags
}

resource "aws_subnet" "fs-private-subnet-c" {
    vpc_id                  = aws_vpc.fs-vpc.id
    availability_zone       = "${data.aws_region.current_region.name}c"
    cidr_block              = cidrsubnet(aws_vpc.fs-vpc.cidr_block, 4, 2)
    tags                    = local.common_tags
}
