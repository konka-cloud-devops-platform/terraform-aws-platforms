variable "rules" {
  description = "Security group rules"
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    description              = string

    security_group_id          = string
    source_security_group_id   = optional(string)
    cidr_blocks                = optional(list(string))
    self                       = optional(bool)
  }))
}