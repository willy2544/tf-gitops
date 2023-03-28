resource "aws_instance" "webserver_private" {
  ami = data.aws_ami.nginx_ami.id

  count             = length(data.aws_subnets.private_subnets.ids)
  instance_type     = "t1.micro"
  availability_zone = element(data.aws_subnet.private_subnet.*.availability_zone, count.index)
  subnet_id         = element(data.aws_subnet.private_subnet.*.id, count.index)

  lifecycle {
    # ignore_changes = [ami]
    create_before_destroy = true
  }
}

resource "aws_lb" "LoadBalance" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = data.aws_subnets.public_subnets.ids
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from VPC"
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
  tags = {
    Name = "security_group"
  }
}

resource "aws_alb_listener" "ALBListen" {
  load_balancer_arn = aws_lb.LoadBalance.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}

resource "aws_lb_target_group" "target" {
  target_type = "instance"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200" # has to be HTTP 200 or fails
  }
}

resource "aws_lb_target_group_attachment" "test" {
  count            = length(aws_instance.webserver_private.*)
  target_group_arn = aws_lb_target_group.target.arn
  target_id        = element(aws_instance.webserver_private.*.id, count.index)
  port             = 80
}