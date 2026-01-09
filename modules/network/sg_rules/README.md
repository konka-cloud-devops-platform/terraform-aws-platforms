# Security Group Rules Terraform Module

This module manages **AWS Security Group rules** using `aws_security_group_rule`.

It supports **multiple ingress and egress rules** using `for_each` and keeps rules **separate from the Security Group** for better control and stability.

---

## What this module does

- Creates **multiple Security Group rules** dynamically
- Supports:
  - Ingress and Egress rules
  - CIDR-based rules
  - Security Group to Security Group rules
  - Self-referencing rules
- Avoids recreating the Security Group when rules change

---

## Why rules are separated from Security Group

Terraform best practice is to **not define rules inside `aws_security_group`**.

Benefits:
- No unnecessary SG recreation
- Easier rule management
- Supports dynamic and conditional rules
- Cleaner and reusable design

---

## Inputs (Variables)

### `rules`

Map of security group rules.

| Field Name | Description | Required |
|----------|-------------|----------|
| `type` | `ingress` or `egress` | Yes |
| `from_port` | Start port | Yes |
| `to_port` | End port | Yes |
| `protocol` | Protocol (tcp, udp, icmp, -1) | Yes |
| `description` | Rule description | Yes |
| `security_group_id` | Target SG ID | Yes |
| `cidr_blocks` | CIDR ranges | Optional |
| `source_security_group_id` | Source SG ID | Optional |
| `self` | Allow traffic from same SG | Optional |

---

## Example Rules Map

### Ingress from CIDR

```hcl
rules = {
  ssh_ingress = {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    description       = "Allow SSH from office IP"
    security_group_id = module.bastion_sg.sg_id
    cidr_blocks       = ["203.0.113.0/24"]
  }
}
````

---

### Ingress from another Security Group

```hcl
rules = {
  app_to_db = {
    type                       = "ingress"
    from_port                  = 3306
    to_port                    = 3306
    protocol                   = "tcp"
    description                = "Allow MySQL from app SG"
    security_group_id           = module.db_sg.sg_id
    source_security_group_id    = module.app_sg.sg_id
  }
}
```

---

### Self-referencing rule

```hcl
rules = {
  internal_traffic = {
    type              = "ingress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    description       = "Allow internal SG traffic"
    security_group_id = module.app_sg.sg_id
    self              = true
  }
}
```

---

### Egress rule (Allow all)

```hcl
rules = {
  allow_all_egress = {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    description       = "Allow all outbound traffic"
    security_group_id = module.app_sg.sg_id
    cidr_blocks       = ["0.0.0.0/0"]
  }
}
```

---

## Example Module Usage

```hcl
module "sg_rules" {
  source = "./modules/security-group-rules"

  rules = {
    ssh_ingress = {
      type              = "ingress"
      from_port         = 22
      to_port           = 22
      protocol          = "tcp"
      description       = "SSH access"
      security_group_id = module.bastion_sg.sg_id
      cidr_blocks       = ["0.0.0.0/0"]
    }
  }
}
```

---

## Design Decisions

* **`for_each` used instead of `count`**
  → Easier to manage multiple rules
  → Rule-level tracking in Terraform state

* **`lookup()` for optional fields**
  → Avoids forcing unused attributes
  → Supports flexible rule definitions

* **Rules separated from SG**
  → Prevents accidental SG replacement
  → Matches Terraform and AWS best practices

---

## Best Practices Followed

* DRY and reusable module
* Environment-agnostic
* Supports real-world SG patterns
* Clean separation of responsibilities

---

## When to use this module

* When managing multiple SG rules
* When working with microservices or tier-based architecture
* When you want safer Terraform applies without SG recreation

---
