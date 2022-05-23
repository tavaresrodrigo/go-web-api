module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  name = "${var.name}-ecs-cluster"
  container_insights = false
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight = "1"
    }
  ]
  tags = merge(
    local.tags,
    {
      Name = "${var.name}-ecs-cluster"
    }
  )

}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  task_role_arn = aws_iam_role.gowebapi-task-execution-role.arn
  execution_role_arn       = aws_iam_role.gowebapi-task-execution-role.arn
  family = "fargate-task-definition"

  container_definitions = jsonencode([
    {
      name = "${var.container_name}"
      image = "tavaresrodrigo/go-web-api:v1"
      logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group" = "${aws_cloudwatch_log_group.cloudwatch-log-group.name}"
            "awslogs-stream-prefix" = "${var.name}-log-stream"
            "awslogs-region" = "${var.region}"
            }
      }
      portMappings = [
        {
          containerPort = 8080
          hostPort = 8080
          protocol = "tcp"
        }
      ]
    }
  ])
  tags = merge(
    local.tags,
    {
      Name = "${var.name}-fargate-task-definition"
    }
  )
}

resource "aws_ecs_service" "ecs-service" {
  name = "container-ecs-service"
  cluster = "${var.name}-ecs-cluster"
  task_definition = aws_ecs_task_definition.ecs-task-definition.id
  desired_count = 1
  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0
  network_configuration {
    subnets = "${aws_subnet.public-subnet.*.id}"   
    security_groups = ["${aws_security_group.ecs-cluster-sg.id}"]
    assign_public_ip = "true"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }
  tags = merge(
    local.tags,
    {
      Name = "${var.name}-ecs-service"
    }
  )
}

