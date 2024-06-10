##---------- Here we are using terraform-aws-securitygroup module folder (we can push the module to git and give git url here)
##----------Below code refers to creating Security groups for db, backend, frontend, bastion, application Load balancer, VPN instances

module "db" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_name = "db"
  sg_description = "Security group for DB MySQL instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

module "backend" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_name = "backend"
  sg_description = "Security group for backend instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

module "frontend" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_name = "frontend"
  sg_description = "Security group for frontend instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

module "bastion" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_name = "bastion"
  sg_description = "Security group for bastion instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

module "app_alb" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_name = "app_alb"
  sg_description = "Security group for app_alb instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}


module "vpn" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_name = "vpn"
  sg_description = "Security group for VPN instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  inbound_rules = var.vpn_sg_rules
}

module "web_alb" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for Web ALB Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_name = "web-alb"
}

##----------Below code is for creating Security group rules to control inbound traffic (refer sg_rules.yaml for the flow)

##-----------------------------------DB rules------------------------------------------------------------

# DB is accepting connections from backend
resource "aws_security_group_rule" "db_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend.sg_id # source is where you are getting traffic from
  security_group_id = module.db.sg_id
}

# DB is accepting connections from bastion
resource "aws_security_group_rule" "db_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id = module.db.sg_id
}

# DB is accepting connections from vpn
resource "aws_security_group_rule" "db_vpn" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id = module.db.sg_id
}

##----------------------------------------Backend rules-----------------------------------------------------------------------

# Backend is accepting connections from app ALB
resource "aws_security_group_rule" "backend_app_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb.sg_id # source is where you are getting traffic from
  security_group_id = module.backend.sg_id
}

# Backend is accepting connections from bastion
resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id = module.backend.sg_id
}

# Backend is accepting connections from vpn SSH
resource "aws_security_group_rule" "backend_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id = module.backend.sg_id
}

# Backend is accepting connections from vpn port
resource "aws_security_group_rule" "backend_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id = module.backend.sg_id
}


##----------------------------------------App ALB rules-----------------------------------------------------------------------

# app ALB is accepting connections from vpn
resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.app_alb.sg_id
}

# app ALB is accepting connections from bastion
resource "aws_security_group_rule" "app_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id = module.app_alb.sg_id
}

# app ALB is accepting connections from frontend
resource "aws_security_group_rule" "app_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.frontend.sg_id # source is where you are getting traffic from
  security_group_id = module.app_alb.sg_id
}


##----------------------------------------Frontend rules-----------------------------------------------------------------------

# frontend is accepting connections from Internet/Public
# resource "aws_security_group_rule" "frontend_public" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
#   security_group_id = module.frontend.sg_id
# }

# frontend is accepting connections from web load balancer
resource "aws_security_group_rule" "frontend_web_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_alb.sg_id 
  security_group_id = module.frontend.sg_id
}

# frontend is accepting connections from bastion
resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.frontend.sg_id
}

# frontend is accepting connections from vpn
resource "aws_security_group_rule" "frontend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id = module.frontend.sg_id
}


##----------------------------------------Web Load balancer rules-----------------------------------------------------------------------

# Web load balancer is accepting connections from public using http
resource "aws_security_group_rule" "web_alb_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb.sg_id
}

# Web load balancer is accepting connections from public using https
resource "aws_security_group_rule" "web_alb_public_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb.sg_id
}


##----------------------------------------Bastion rules-----------------------------------------------------------------------

# bastion is accepting connections from Internet/Public
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}