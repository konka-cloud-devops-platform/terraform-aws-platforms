locals {
  sg_map = {
    bastion            = module.bastion.sg_id
    vpn                = module.vpn.sg_id
    rds                = module.rds.sg_id
    elasticache        = module.elasticache.sg_id
    controlplane       = module.controlplane.sg_id
    nodegroup          = module.nodegroup.sg_id
    external_alb       = module.external_alb.sg_id
    interface_endpoint = module.interface_endpoint_sg.sg_id
  }


  resolved_sg_rules = {
    for name, rule in var.sg_rules :
    name => {
      type        = rule.type
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      description = rule.description

      # Target SG (always required)
      security_group_id = local.sg_map[rule.security_group_name]

      # Optional fields
      cidr_blocks = lookup(rule, "cidr_blocks", null)
      self        = lookup(rule, "self", null)

      # Source SG (ONLY if key exists AND value is not null)
      source_security_group_id = (
        contains(keys(rule), "source_security_group_name") &&
        rule.source_security_group_name != null
      ) ? local.sg_map[rule.source_security_group_name] : null
    }
  }


}