variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "expense"
    Environment = "dev"
    Terraform = "true"
  }
}

variable "vpn_sg_rules" {
    default = [
        {
            from_port = 943
            to_port = 943
            allowed_cdir = ["0.0.0.0/0"]
            protocol = "tcp" #all protocols
        },
        {
            from_port = 443
            to_port = 443
            allowed_cdir = ["0.0.0.0/0"]
            protocol = "tcp" #all protocols
        },
        {
            from_port = 22
            to_port = 22
            allowed_cdir = ["0.0.0.0/0"]
            protocol = "tcp" #all protocols
        },
        {
            from_port = 1194
            to_port = 1194
            allowed_cdir = ["0.0.0.0/0"]
            protocol = "udp" #all protocols
        }
    ]
}

