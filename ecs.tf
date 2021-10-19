module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "3.4.0"
  name = "confluent-ansible-provisioner"
  container_insights = true
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]

  tags = {
    Environment = "Development"
  }
}

data "aws_iam_role" "ecs" {
  name = "AWSServiceRoleForECS"
}

resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "cp-ansible"
      image     = "osodevops/cp-ansible:latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.cp-ansible.id
      root_directory          = "/opt/data"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.cp-ansible.id
        iam             = "ENABLED"
      }
    }
  }

  task_role_arn = data.aws_iam_role.ecs.arn

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

