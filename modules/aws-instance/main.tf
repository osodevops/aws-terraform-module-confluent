data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  count = var.instance_count

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_group_ids

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<html><body><div>Hello, world!</div></body></html>" > /var/www/html/index.html
    EOF

  tags = {
    Terraform   = "true"
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.name}-${count.index}"
  }
}

resource "aws_ebs_volume" "pm-ebs" {
  count = var.data_disk_size > 0 ? var.instance_count : 0
  availability_zone = "eu-west-2a"
  size              = 4500
  encrypted = true

  tags = {
    Name = "pm-${var.environment}"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  count = var.data_disk_size > 0 ? var.instance_count : 0
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.pm-ebs[count.index].id
  instance_id = aws_instance.app[count.index].id
}
