#Below code refers to creating an application Load Balancer 
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-${var.environment}-app-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.app_alb_sg_id.value]
  subnets            = split(",", data.aws_ssm_parameter.private_subnet_ids.value)

  enable_deletion_protection = false

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-app-alb"
    }
  )
}

# Every load balancer should have a listener to recieve incoming requests and direct it to Target group 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

# Here we gave default response when there are no target groups associated ex: some.app-dev.avyan.site gives this content
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>This is fixed response from APP ALB</h1>" # Here we are sending fixed response to check if it is recieving requests.. this will be replaced with target group
      status_code  = "200"
    }
  }
}


#Below code refers to updating Route53 records with load balancer DNS name
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name
  
  records = [
    {
      name    = "*.app-${var.environment}" # In large applications, it will be like cart.app-dev.avyan.site, billing.app-dev.avyan.site...
      type    = "A"
      allow_overwrite = true
      alias   = {
        name    = aws_lb.app_alb.dns_name
        zone_id = aws_lb.app_alb.zone_id
      }
    }
  ]
}