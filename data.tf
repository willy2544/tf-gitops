data "aws_ami" "nginx_ami" {
  most_recent = true
  owners      = ["979382823631"]

  filter {
    name   = "name"
    values = ["bitnami-nginx-1.21.6-26-r04-linux-debian-10-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Name = "public_subnet_*"
  }
}

data "aws_subnet" "public_subnet" {
  count = "${length(data.aws_subnets.public_subnets.ids)}"
  id    = "${data.aws_subnets.public_subnets.ids[count.index]}"
  depends_on = [
    data.aws_subnets.public_subnets
  ]
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Name = "private_subnet_*"
  }
}

data "aws_subnet" "private_subnet" {
  count = "${length(data.aws_subnets.private_subnets.ids)}"
  id    = "${data.aws_subnets.private_subnets.ids[count.index]}"
}



#### outputs ####
# output "public_subnets" {
#   value = [data.aws_subnets.public_subnets.ids]
# }

# output "public_subnet_cidr_blocks" {
#   value = data.aws_subnet.public_subnet.*.cidr_block
# }

# output "private_subnets" {
#   value = [data.aws_subnets.private_subnets.ids]
# }

# output "private_subnet_cidr_blocks" {
#   value = data.aws_subnet.private_subnet.*.cidr_block
# }