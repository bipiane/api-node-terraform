# Security Group EC2
resource "aws_security_group" "ec2_sg" {
  name   = "${var.app_name}-ec2-sg"
  vpc_id = aws_vpc.node-api_vpc.id
  tags   = {
    Name = "${var.app_name}-ec2-sg"
  }

  # Ingress/Inbound only from ALB or SSH
  ingress {
    from_port       = 80
    to_port         = var.server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Warning: ingress from Internet
  #  ingress {
  #    from_port   = 80
  #    to_port     = var.server_port
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Full Egress/Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group ELB
resource "aws_security_group" "alb_sg" {
  name   = "${var.app_name}-alb-sg"
  vpc_id = aws_vpc.node-api_vpc.id
  tags   = {
    Name = "${var.app_name}-alb-sg"
  }

  # Ingress/Inbound from internet and only HTTP port 80
  ingress {
    from_port   = 80
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Full Egress/Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Template EC2
resource "aws_launch_template" "app_lt" {
  name                   = "${var.app_name}-lt"
  # Amazon Linux 2023 AMI 2023.1.20230825.0 x86_64 HVM kernel-6.1 (ami-0358953f952e7ee66)
  image_id               = "ami-0358953f952e7ee66"
  key_name               = "EC2 Tutorial"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  instance_type          = "t2.micro"

  user_data = filebase64("${path.module}/ec2-user-data.sh")

  tag_specifications {
    resource_type = "instance"
    tags          = {
      Name = var.app_name
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = {
      Name = var.app_name
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name             = "${var.app_name}-asg"
  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  health_check_type = "ELB"

  vpc_zone_identifier = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id
  ]

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app_lt.id
      }
      override {
        instance_type = "t2.micro"
      }
    }
  }
}

resource "aws_autoscaling_policy" "app_asp" {
  name                   = "${var.app_name}-asp"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name

  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 25.0
  }
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.app_name}-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.node-api_vpc.id

  health_check {
    enabled             = true
    port                = var.server_port
    protocol            = "HTTP"
    path                = "/health"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 2
    interval            = 30
  }
}

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "${var.app_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id
  ]

  tags = {
    Name = "${var.app_name}-lb"
  }
}

resource "aws_lb_listener" "app_alb_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = {
    Name = "${var.app_name}-lb-listener"
  }
}
