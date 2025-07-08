resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "project-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "project-igw"
  }
}

resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, each.key)
  tags = {
    Name = "project-public-${each.key}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "project-public-rt"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instance" {
  name   = "instance-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app" {
  name               = "project-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = values(aws_subnet.public)[*].id
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "app1" {
  name     = "tg-app1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "app2" {
  name     = "tg-app2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "app1" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app1.arn
  }
  condition {
    path_pattern {
      values = ["/path1/*"]
    }
  }
}

resource "aws_lb_listener_rule" "app2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app2.arn
  }
  condition {
    path_pattern {
      values = ["/path2/*"]
    }
  }
}

resource "aws_launch_template" "app1" {
  name_prefix   = "lt-app1-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.app1_instance_type
  user_data     = base64encode(file("${path.module}/user_data_app1.sh"))
  vpc_security_group_ids = [aws_security_group.instance.id]
}

resource "aws_launch_template" "app2" {
  name_prefix   = "lt-app2-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.app2_instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

resource "aws_autoscaling_group" "app1" {
  name                      = "asg-app1"
  vpc_zone_identifier       = values(aws_subnet.public)[*].id
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  health_check_type         = "EC2"
  launch_template {
    id      = aws_launch_template.app1.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.app1.arn]
}

resource "aws_autoscaling_group" "app2" {
  name                      = "asg-app2"
  vpc_zone_identifier       = values(aws_subnet.public)[*].id
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  health_check_type         = "EC2"
  launch_template {
    id      = aws_launch_template.app2.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.app2.arn]
}
