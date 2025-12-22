# VPC Terraform Module

This module creates a **production-ready AWS VPC** with support for:

* Public, Private, and DB subnets across multiple AZs
* Internet Gateway
* Optional NAT Gateway
* Route tables and associations
* RDS DB subnet group
* Optional VPC Flow Logs to CloudWatch

The module is designed to be **reusable across environments** such as `dev`, `stage`, `uat`, and `prod`.

---

## Architecture Overview

The module provisions the following components:

* **VPC** with DNS support enabled
* **Public Subnets**

  * One per Availability Zone
  * Routed to Internet Gateway
* **Private Subnets**

  * One per Availability Zone
  * Routed to NAT Gateway (optional)
* **DB Subnets**

  * One per Availability Zone
  * Isolated from direct internet access
* **NAT Gateway** (optional)

  * Single NAT Gateway for outbound internet access
* **VPC Flow Logs** (optional)

  * Delivered to CloudWatch Logs

---

## Subnet Strategy

For a 3-AZ region, the module typically creates:

* 3 Public subnets (1 per AZ)
* 3 Private subnets (1 per AZ)
* 3 DB subnets (1 per AZ)

Subnets are named using AZ suffixes for clarity, for example:

```
<project>-<env>-public-subnet-a
<project>-<env>-private-subnet-b
<project>-<env>-db-subnet-c
```

---

## Features

* Multi-AZ subnet design
* Centralized tagging using `common_tags`
* Optional NAT Gateway for private and DB subnets
* Optional VPC Flow Logs with CloudWatch integration
* Clean separation of routing for public, private, and DB tiers

---

## Usage Example

```hcl
module "vpc" {
  source = "../../modules/vpc"

  project_name = "moneylag"
  environment  = "dev"

  vpc_cidr_block = "10.0.0.0/16"

  availability_zone = [
    "ap-south-1a",
    "ap-south-1b",
    "ap-south-1c"
  ]

  public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidr_blocks = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  db_subnet_cidr_blocks      = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  enable_nat_gateway       = true
  enable_vpc_flow_logs_cw  = true

  common_tags = {
    Project     = "moneylag"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

---

## Inputs

| Name                         | Description                           |
| ---------------------------- | ------------------------------------- |
| `project_name`               | Project name used for resource naming |
| `environment`                | Environment name (dev, stage, prod)   |
| `vpc_cidr_block`             | CIDR block for the VPC                |
| `availability_zone`          | List of availability zones            |
| `public_subnet_cidr_blocks`  | CIDR blocks for public subnets        |
| `private_subnet_cidr_blocks` | CIDR blocks for private subnets       |
| `db_subnet_cidr_blocks`      | CIDR blocks for DB subnets            |
| `enable_nat_gateway`         | Enable or disable NAT Gateway         |
| `enable_vpc_flow_logs_cw`    | Enable or disable VPC Flow Logs       |
| `common_tags`                | Tags applied to all resources         |

---

## Outputs

| Name                   | Description                |
| ---------------------- | -------------------------- |
| `vpc_id`               | VPC ID                     |
| `public_subnet_ids`    | List of public subnet IDs  |
| `private_subnet_ids`   | List of private subnet IDs |
| `db_subnet_ids`        | List of DB subnet IDs      |
| `db_subnet_group_name` | RDS DB subnet group name   |

---

## Notes

* This module uses a **single NAT Gateway** when enabled (cost-optimized design).
* VPC Flow Logs are optional and sent to **CloudWatch Logs** with retention configured.
* The module does not hardcode environment-specific values and is safe for reuse.

---

## Interview-Ready One-Liner

> “This VPC module creates a multi-AZ network with public, private, and DB subnets, optional NAT Gateway, and optional VPC Flow Logs. It’s reusable across environments and designed with production traffic flow in mind.”


