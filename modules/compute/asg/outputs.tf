output "lt_arn" {
  value = aws_launch_template.foo.arn
}
output "lt_id" {
  value = aws_launch_template.foo.id
}
output "asg_arn" {
  value = aws_autoscaling_group.bar.arn
}
output "asg_id" {
  value = aws_autoscaling_group.bar.id
}