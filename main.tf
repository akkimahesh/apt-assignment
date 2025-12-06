
# Application Load Balancer

resource "aws_lb" "assignment_alb" {
  name               = "assignment-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets = [
    aws_subnet.public-1.id,
    aws_subnet.public-2.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "alb-lb"
  }
}


# Target Group
resource "aws_lb_target_group" "assignment_tg" {
  name        = "assignment-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.assignment-vpc.id
  target_type = "instance"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "assignment-tg"
  }
}



# Listener

resource "aws_lb_listener" "assignment" {
  load_balancer_arn = aws_lb.assignment_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.assignment_tg.arn
  }
}


# Launch Template 

resource "aws_launch_template" "amazon_linux_lt" {
  name_prefix   = "nodejs-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.test_profile.name
  }

  user_data = base64encode(file("user-data.sh"))
}


# IAM Role

resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


# IAM Instance Profile

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_role_profile"
  role = aws_iam_role.test_role.name
}


# IAM Policies

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# Auto Scaling Group 

resource "aws_autoscaling_group" "assignment_asg" {
  launch_template {
    id      = aws_launch_template.nodejs_lt.id
    version = "$Latest"
  }

  min_size         = 2
  max_size         = 2
  desired_capacity = 2

  vpc_zone_identifier = [
    aws_subnet.private-1.id,
    aws_subnet.private-2.id
  ]

  target_group_arns = [aws_lb_target_group.assignment_tg.arn]

  tag {
    key                 = "Name"
    value               = "nodejs-server"
    propagate_at_launch = true
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
  }
}


# Output

output "application_load_balancer_dns_name" {
  value = aws_lb.assignment_alb.dns_name
}
