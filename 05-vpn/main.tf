##-----------This will create new public and private key and this will be used in VPN resource creation

resource "aws_key_pair" "vpn" {
  key_name   = "openvpn"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5o0fdavYVzgh3ceTzeKqZYL3CnLtwvE+PQ6D8EIDmH nares@Avyan"
  public_key = file("~/.ssh/openvpn.pub") # go to any path, here we are using ~/.ssh/ and create new key using command ssh-keygen -f <file-name>
  # ~ means windows home directory
}

##-----Below code creates an EC2 instance named expense-dev-vpn
##-----Here ec2 instance creation is done from using an open source module which is safe

module "vpn" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-vpn"
  key_name = aws_key_pair.vpn.key_name
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  # convert StringList to list and get first element
  subnet_id = local.public_subnet_id
  ami = data.aws_ami.ami_info.id
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-vpn"
    }
  )
}