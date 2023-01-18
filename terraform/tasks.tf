
// The core variable for this deployment. Define the task
// using a docker image, the ports it will use, and the
// resources it will need.
resource "aws_ecs_task_definition" "server" {
    family = var.project_name
    container_definitions = <<DEFINITION
    [
        {
            "name": "${var.project_name}",
            "image": "${var.docker_image}",
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 9003,
                    "hostPort": 9003
                },
                {
                    "containerPort": 9004,
                    "hostPort": 9004
                },
                {
                    "containerPort": 9005,
                    "hostPort": 9005
                }
            ],
            "memory": 512,
            "cpu": 256
        }
    ]
    DEFINITION

    requires_compatibilities = [ "FARGATE" ]
    network_mode = "awsvpc"
    memory = 512
    cpu = 256
    execution_role_arn = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}