data "aws_ami" "ubuntu_2004" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_security_group" "mongo_vm" {
  name        = "mongo-vm-sg"
  description = "mongo vm"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH - intentionally open, this is the lab weakness"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MongoDB from private subnets only"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "mongo_vm" {
  name = "mongo-vm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "mongo_vm_ec2" {
  role       = aws_iam_role.mongo_vm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "mongo_vm_s3" {
  role       = aws_iam_role.mongo_vm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "mongo_vm" {
  name = "mongo-vm-profile"
  role = aws_iam_role.mongo_vm.name
}

resource "aws_key_pair" "wiz_lab" {
  key_name   = "wiz-lab"
  public_key = file("${path.module}/wiz-lab.pub")
}

resource "aws_instance" "mongo_vm" {
  ami                         = data.aws_ami.ubuntu_2004.id
  instance_type               = "t3.small"
  key_name                    = aws_key_pair.wiz_lab.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.mongo_vm.id]
  iam_instance_profile        = aws_iam_instance_profile.mongo_vm.name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/mongo_user_data.sh.tpl", {
    backup_password = var.backup_password
    tasky_password  = var.tasky_password
    bucket_name     = aws_s3_bucket.backup.bucket
  })

  tags = { Name = "mongo-vm" }
}
