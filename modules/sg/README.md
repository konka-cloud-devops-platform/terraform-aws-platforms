# Security Group Terraform Module

This module creates an AWS Security Group with a standard naming convention and common tags.

It is designed to be reusable across environments (dev, qa, prod) by passing values through variables.

---

## What this module does

- Creates an AWS Security Group in a given VPC
- Applies consistent naming using **Project + Environment + SG name**
- Attaches common tags to follow tagging standards
- Exposes the Security Group ID as an output

⚠️ Note:  
This module **only creates the Security Group**.  
Ingress and egress rules should be managed separately (recommended for better control and modularity).

---

## Naming Convention

Security Group name format:

```

<Project>-<Environment>-<sg_name>

```

Example:
```

moneylag-dev-bastion

```

Tag `Name` will be:
```

moneylag-dev-bastion-sg

````

---

## Inputs (Variables)

| Variable Name     | Description                              | Type          | Required |
|------------------|------------------------------------------|---------------|----------|
| `sg_name`        | Logical name of the Security Group        | `string`      | Yes |
| `sg_description` | Description for the Security Group        | `string`      | Yes |
| `vpc_id`         | VPC ID where SG will be created           | `string`      | Yes |
| `common_tags`    | Common tags (Project, Environment, etc.)  | `map(string)` | Yes |

---

## Example `common_tags`

```hcl
common_tags = {
  Project     = "moneylag"
  Environment = "dev"
  Owner       = "devops-team"
}
````

---

## Outputs

| Output Name | Description                      |
| ----------- | -------------------------------- |
| `sg_id`     | ID of the created Security Group |

---

## Example Usage

```hcl
module "bastion_sg" {
  source = "./modules/security-group"

  sg_name        = "bastion"
  sg_description = "Security group for bastion host"
  vpc_id         = var.vpc_id

  common_tags = {
    Project     = "moneylag"
    Environment = "dev"
    Owner       = "devops-team"
  }
}
```
---

## Best Practices Followed

* Reusable Terraform module
* Environment-agnostic design
* Clean separation of concerns (SG vs rules)
* Consistent tagging strategy

---

## When to use this module

* When you want standardized Security Groups
* When working with multi-environment infrastructure
* When following DRY principles in Terraform

---

