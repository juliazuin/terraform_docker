provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = "chave_development_julia"  # key chave publica cadastrada na AWS 
  subnet_id                   = "subnet-0734ecf92f4be11fa" # vincula a subnet direto e gera o IP automático
  private_ip                  = "10.10.10.100"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.allow_ssh_ansible.id}",
  ]
  root_block_device {
    encrypted  = true
    kms_key_id = "arn:aws:kms:us-east-1:534566538491:key/90847cc8-47e8-4a75-8a69-2dae39f0cc0d" #key managment service (aws) -> awsmanaged keys -> aws/ebs -> copy arn
    # volume_size = 8
  }

  tags = {
    Name = "ec2_tf_Julia"
  }
}

resource "aws_eip" "example" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.example.id
}

# terraform refresh para mostrar o ssh

output "aws_instance_e_ssh" {
  value = [
    aws_instance.web.public_ip,
    "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.web.public_dns}"
  ]
}

resource "aws_security_group" "allow_ssh_ansible_nginx" {
  name        = "allow_ssh_ansible_nginx"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-063fc945cde94d3ab"

  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups  = null,
      self             = null
    },
    {
      description      = "SSH from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups  = null,
      self             = null
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"],
      description : "Libera dados da rede interna"
      prefix_list_ids = []
      security_groups = []
      self            = false
    }
  ]

  tags = {
    Name = "allow_ssh_ansible_nginx"
  }
}

output "allow_ssh_ansible_nginx" {
  value = aws_security_group.allow_ssh_ansible_nginx.id
}