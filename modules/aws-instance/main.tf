data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_subnet" "selected" {
  count = var.instance_count
  id = var.subnet_ids[count.index]
}

data "template_file" "bootstrap-confluent" {
  template = file("${path.module}/${var.user_data_template}")
  vars = {
    file_system_id = var.efs_file_system_id
  }
}

resource "aws_instance" "app" {
  count = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_pair
  user_data              = data.template_file.bootstrap-confluent.rendered

  tags = {
    Terraform   = "true"
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.name}-${count.index}"
  }

}

resource "aws_ebs_volume" "pm-ebs" {
  count = var.data_disk_size > 0 ? var.instance_count : 0
  availability_zone = element(data.aws_subnet.selected.*.availability_zone, count.index)
  size              = 4500
  encrypted = false
  tags = {
    Name = "${var.name}-${var.environment}-${count.index}"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  count = var.data_disk_size > 0 ? var.instance_count : 0
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.pm-ebs[count.index].id
  instance_id = aws_instance.app[count.index].id
}

resource "aws_route53_record" "www" {
  count = var.instance_count
  zone_id = var.internal_dns_zone_id
  name    = "${var.name}-${count.index}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.app[count.index].private_ip]
}