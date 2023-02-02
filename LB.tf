resource "aws_lb" "project-load-balancer" {
#   count = var.instance_count
  name               = "project-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.project-load-balancer-sg.id]
  subnets            = aws_subnet.subnets[*].id

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "project-target-group" {
  name        = "project-target-group"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.mini-project.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200-299"
    interval = 15
    timeout = 3
    healthy_threshold = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "project-target-group-attachment" {
  count  = var.instance_count

  target_group_arn = aws_lb_target_group.project-target-group.arn
  target_id = aws_instance.instances[count.index].id
  port             = 80
}

resource "aws_lb_listener" "project-listener" {
  load_balancer_arn = aws_lb.project-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project-target-group.arn
  }
}

resource "aws_lb_listener_rule" "project-listener-rule" {
  listener_arn = aws_lb_listener.project-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project-target-group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}
