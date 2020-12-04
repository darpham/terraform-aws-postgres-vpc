output "security_group_id" {
  value = aws_security_group.alb.id
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.default.arn
}
// output "aws_alb_var" {
//   value = aws_alb.alb
// }

// output "alb_lb_listener_http_var" {
//   value = aws_lb_listener.http
// }

output lb_dns_name {
  value = aws_lb.alb.dns_name
}

output lb_arn {
  value = aws_lb.alb.arn
}