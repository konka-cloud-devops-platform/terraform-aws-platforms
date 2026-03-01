data "aws_secretsmanager_secret" "rds" {
  arn = "arn:aws:secretsmanager:ap-south-1:384570460482:secret:3-tier/secrets-bqgn5E"
}
data "aws_secretsmanager_secret_version" "rds" {
  secret_id = data.aws_secretsmanager_secret.rds.id
}
data "aws_ssm_parameter" "ec2_key" {
  name            = "/ssh/siva"
  with_decryption = true
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "openvpn" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["OpenVPN Access Server Community Image-fe8020db-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "backend_ami" {
  most_recent = true
  owners      = ["522814728660"]

  filter {
    name   = "name"
    values = ["backend-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "frontend_ami" {
  most_recent = true
  owners      = ["522814728660"]

  filter {
    name   = "name"
    values = ["frontend-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}