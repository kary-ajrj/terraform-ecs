provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name="terraform-VPC"
  }
}

resource "aws_subnet" "ecs_subnet" {
  vpc_id = aws_vpc.ecs_vpc.id
  cidr_block = "10.0.0.0/28"
  availability_zone = "ap-northeast-1a"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "terraform-cluster"
}

resource "aws_launch_configuration" "launch_config" {
  image_id      = "ami-06ee4e2261a4dc5c3"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "auto_scale" {
  max_size = 1
  min_size = 1
  launch_configuration = aws_launch_configuration.launch_config.name
  vpc_zone_identifier = [aws_subnet.ecs_subnet.id]
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "capacity_provider_example"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.auto_scale.arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]
  default_capacity_provider_strategy {
    base = 1
    weight = 100
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
  }
}
