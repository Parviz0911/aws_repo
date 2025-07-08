output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}

output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.main.id
}
