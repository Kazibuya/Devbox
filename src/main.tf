resource "aws_key_pair" "dev" {
  key_name = "dev-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "dev" {
  vpc_id = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "dev-subnet"
  }
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev.id
  }
}

resource "aws_route_table_association" "dev" {
  subnet_id = aws_subnet.dev.id
  route_table_id = aws_route_table.dev.id
}

resource "aws_security_group" "dev" {
  name = "dev-sg"
  vpc_id = aws_vpc.dev.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "dev" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.dev.id
  vpc_security_group_ids = [aws_security_group.dev.id]
  key_name = aws_key_pair.dev.key_name
  iam_instance_profile = aws_iam_instance_profile.dev_ec2.name
  user_data = file("${path.module}/user_data.sh")
  tags = {
    Name = "dev"
  }
}

resource "aws_iam_role" "dev_ec2" {
  name = "dev-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "dev_ec2" {
  role = aws_iam_role.dev_ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "secretsmanager:GetSecretValue"
      Effect = "Allow"
      Resource = "arn:aws:secretsmanager:eu-north-1:*:secret:dev-ec2/*"
    }]
  })
}

resource "aws_iam_instance_profile" "dev_ec2" {
  name = "dev-ec2-instance-profile"
  role = aws_iam_role.dev_ec2.name
}
