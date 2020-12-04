data "template_file" "task_definition" {
  template = file("templates/task-definition.json")
  vars     = {
    container_memory = var.container_memory
    container_cpu    = var.container_cpu
    container_port   = var.container_port
    container_name   = var.container_name
    cluster_name     = var.cluster_name
    task_name        = var.task_name
    region           = var.region

    // TODO: Use remote Docker Image Repository
    #image_tag       = var.image_tag

    # Secrets injected securely from AWS SSM systems manager param store
    # https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html
    # token_secret      = data.aws_ssm_parameter.token_secret.arn
    db_hostname       = var.aws_ssm_db_hostname_arn
    postgres_password = var.aws_ssm_db_password_arn
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "task" {
  family = var.task_name

  container_definitions    = data.template_file.task_definition.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.container_memory
  cpu                      = var.container_cpu
  execution_role_arn       = aws_iam_role.task_exec_role.arn
  task_role_arn            = aws_iam_role.task_exec_role.arn
}

resource "aws_ecs_service" "svc" {
  name            = var.task_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  load_balancer {
    container_name   = var.container_name
    container_port   = var.container_port
    target_group_arn = var.alb_target_group_arn
  }

  network_configuration {
    subnets          = tolist(var.public_subnet_ids)
    security_groups  = [aws_security_group.svc_sg.id, var.db_security_group_id, var.bastion_security_group_id]
    assign_public_ip = true
  }
}
