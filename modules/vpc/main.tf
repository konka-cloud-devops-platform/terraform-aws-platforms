###############################################################################
###############                  Locals                   #####################
###############################################################################
locals {
  prefix = "${var.common_tags["Project"]}-${var.common_tags["Environment"]}"
  enabled_endpoints = {
    for k, v in var.vpc_endpoints :
    k => v if v.enabled
  }
}

###############################################################################
###############                  VPC                   #####################
###############################################################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-vpc"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}

###############################################################################
###############                     IGW                   #####################
###############################################################################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-igw"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }

  )
}

###############################################################################
###############                Web,APP & DB Subnets       #####################
###############################################################################
resource "aws_subnet" "web_subnets" {
  count                   = length(var.web_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zone[count.index]
  cidr_block              = var.web_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-web-subnet-${split("-", var.availability_zone[count.index])[2]}"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}

resource "aws_subnet" "app_subnets" {
  count             = length(var.app_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone[count.index]
  cidr_block        = var.app_subnet_cidr_blocks[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-app-subnet-${split("-", var.availability_zone[count.index])[2]}"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}

resource "aws_subnet" "db_subnets" {
  count             = length(var.db_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone[count.index]
  cidr_block        = var.db_subnet_cidr_blocks[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-db-subnet-${split("-", var.availability_zone[count.index])[2]}"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}

###############################################################################
###############                DB Subnet Group            #####################
###############################################################################
resource "aws_db_subnet_group" "default" {
  name       = "${local.prefix}-db-subnet-group"
  subnet_ids = [for db_subnets in aws_subnet.db_subnets : db_subnets.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-db-subnet-group"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }

  )
}

###############################################################################
###############            Web,APP & DB Route Tables      #####################
###############################################################################

resource "aws_route_table" "web_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-web-RT"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}

resource "aws_route_table" "app_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-app-RT"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}

resource "aws_route_table" "db_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-DB-RT"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}
###############################################################################
###############      Subnet Route Table Associations      #####################
###############################################################################
# Subnet Route Table Associations
resource "aws_route_table_association" "web_subnet_association" {
  count          = length(aws_subnet.web_subnets)
  subnet_id      = aws_subnet.web_subnets[count.index].id
  route_table_id = aws_route_table.web_rt.id
}

resource "aws_route_table_association" "app_subnet_association" {
  count          = length(aws_subnet.app_subnets)
  subnet_id      = aws_subnet.app_subnets[count.index].id
  route_table_id = aws_route_table.app_rt.id
}
resource "aws_route_table_association" "db_subnet_association" {
  count          = length(aws_subnet.db_subnets)
  subnet_id      = aws_subnet.db_subnets[count.index].id
  route_table_id = aws_route_table.db_rt.id
}

###############################################################################
###############                 Elastic IP                #####################
###############################################################################
resource "aws_eip" "eip_nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-eip"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}
###############################################################################
###############            NAT Gateway                    #####################
###############################################################################
resource "aws_nat_gateway" "example" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.eip_nat[count.index].id
  subnet_id     = aws_subnet.web_subnets[0].id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-nat-gateway"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )

  depends_on = [aws_internet_gateway.gw]
}

###############################################################################
###############            Web,APP & DB Routes             ####################
###############################################################################
resource "aws_route" "web_route" {
  route_table_id         = aws_route_table.web_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route" "app_nat_route" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.app_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example[count.index].id
}

resource "aws_route" "db_nat_route" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.db_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example[count.index].id
}

###############################################################################
###############            VPC Flow Logs CloudWatch       #####################
###############################################################################

data "aws_iam_policy_document" "assume_role" {
  count = var.enable_vpc_flow_logs_cw ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  count              = var.enable_vpc_flow_logs_cw ? 1 : 0
  name               = "${local.prefix}-vpc-flow-logs-role-cw"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}

data "aws_iam_policy_document" "example" {
  count = var.enable_vpc_flow_logs_cw ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "example" {
  count  = var.enable_vpc_flow_logs_cw ? 1 : 0
  name   = "${local.prefix}-vpc-flow-logs-role-cw-policy"
  role   = aws_iam_role.example[0].id
  policy = data.aws_iam_policy_document.example[0].json
}
resource "aws_flow_log" "example" {
  count           = var.enable_vpc_flow_logs_cw ? 1 : 0
  iam_role_arn    = aws_iam_role.example[0].arn
  log_destination = aws_cloudwatch_log_group.example[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-vpc-flow-logs-role-cw"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}

resource "aws_cloudwatch_log_group" "example" {
  count = var.enable_vpc_flow_logs_cw ? 1 : 0
  name  = "${local.prefix}-vpc-flow-logs-role-cw"
  retention_in_days = 1
}

###############################################################################
###############                VPC Endpoints              #####################
###############################################################################
# resource "aws_vpc_endpoint" "this" {
#   for_each = var.enable_vpc_endpoints ? local.enabled_endpoints : {}

#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.${var.region}.${each.value.service}"
#   vpc_endpoint_type = each.value.type

#   route_table_ids = each.value.type == "Gateway"? [ aws_route_table.app_rt.id,aws_route_table.db_rt.id] : null

#   subnet_ids = each.value.type == "Interface" ?  values(aws_subnet.app_subnets)[*].id : null

#   security_group_ids = each.value.type == "Interface" ? [ var.interface_endpoint_sg_id ]: null

#   private_dns_enabled = each.value.type == "Interface" ? true : null

#   tags = merge(
#     var.common_tags,
#     {
#       Name        = "${local.prefix}-${replace(each.key, "_", "")}-endpoint"
#       Environment = var.common_tags["Environment"]
#       Project     = var.common_tags["Project"]
#     }
#   )
# }


resource "aws_vpc_endpoint" "this" {
  for_each = var.enable_vpc_endpoints ? local.enabled_endpoints : {}

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.${each.value.service}"
  vpc_endpoint_type = each.value.type

  # Gateway endpoint → route tables
  route_table_ids = each.value.type == "Gateway" ? [
        aws_route_table.app_rt.id,
        aws_route_table.db_rt.id ]: null

  # Interface endpoint → app subnets
  subnet_ids = each.value.type == "Interface" ? aws_subnet.app_subnets[*].id : null

  # Interface endpoint → SG
  security_group_ids = each.value.type == "Interface" ? [var.interface_endpoint_sg_id] : null

  private_dns_enabled = each.value.type == "Interface" ? true : null

  tags = merge(
    var.common_tags,
    {
      Name        = "${local.prefix}-${replace(each.key, "_", "-")}-endpoint"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}



# - vpc endpoints are added
# - both gateway and interface types are supported
# - need to be tested
# - Why you're creating endpoints: to allow private connectivity to AWS services without using the internet