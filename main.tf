provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "example-vpc"
  }

}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example"
  }
}


resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "example-subnet"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "example2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "example-subnet2"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group"
  vpc_id      = aws_vpc.example.id

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_efs_file_system" "example" {
  creation_token = "example"
  tags = {
    Name = "example-efs"
  }
}

resource "aws_efs_mount_target" "example" {
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = aws_subnet.example.id
  security_groups = [aws_security_group.example.id]
}

resource "aws_key_pair" "example" {
  key_name   = "example-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3n8MilNTgIZHbBNC3Ay6/1canrx1S2edHW38x0T2E/ kristian.iliev@quanterall.com"
}

resource "aws_launch_configuration" "example" {
  image_id                    = "ami-0b93ce03dcbcb10f6"
  name                        = "example-web-app"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.example.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.example.id
  user_data                   = file("./user_data.sh")



  #   user_data       = <<EOF
  # #!/bin/bash
  # yum install -y httpd
  # echo "Hello, World!" > /var/www/html/index.html
  # service httpd start
  # EOF
}

resource "aws_autoscaling_group" "example" {
  name                 = "example"
  launch_configuration = aws_launch_configuration.example.name
  min_size             = 2
  max_size             = 3
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.example.id]
}

resource "aws_autoscaling_policy" "example" {
  name                   = "example"
  autoscaling_group_name = aws_autoscaling_group.example.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
}

resource "aws_elb" "example" {
  name            = "example"
  security_groups = [aws_security_group.example.id]
  subnets         = [aws_subnet.example.id, aws_subnet.example2.id]
  # load_balancer_type = "application"
  internal = false

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }

  tags = {
    Name = "example-elb"
  }
}

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.example.id
  elb                    = aws_elb.example.id
}

resource "aws_db_subnet_group" "example" {
  name       = "example"
  subnet_ids = [aws_subnet.example.id, aws_subnet.example2.id]

  tags = {
    Name = "Example DB subnet group"
  }
}

resource "aws_db_instance" "example" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "super_secret_password"
  vpc_security_group_ids = [aws_security_group.example.id]
  db_subnet_group_name   = aws_db_subnet_group.example.name
  publicly_accessible    = false
  skip_final_snapshot    = true # TODO: remove this
  tags = {
    Name = "example-rds"
  }
}

resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = "example-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alarm when request count exceeds 10"
  alarm_actions       = [aws_autoscaling_policy.example.arn]
  dimensions = {
    LoadBalancer = aws_elb.example.name
  }
}