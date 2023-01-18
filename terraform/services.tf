
// The meat of this deployment. Define a service by selecting a task definition
// and a cluster. The service will be deployed to the cluster and will use the
// task definition to define the containers that will be deployed.

resource "aws_ecs_service" "markdown_server" {
    name = "markdown-server"
    cluster = "${aws_ecs_cluster.my_default_cluster.id}"
    task_definition = "${aws_ecs_task_definition.markdown_server.arn}"
    launch_type = "FARGATE"
    desired_count = 3

    // We want the service to be load-balanced by our server load balancer
    // and we wanna register the instances we create with the target group.
    load_balancer {
        target_group_arn = "${aws_lb_target_group.markdown_server_target_group.arn}"
        container_name = "${aws_ecs_task_definition.markdown_server.family}"
        container_port = 9003
    }

    // The subnets are the availability zones and the security groups are the
    // ingress/egress rules for the instances. We'll give them both the load balancer
    // security group and the markdown server security group so that the load balancer
    // can talk to the markdown server instances and the markdown server instances can
    // do whatever they please.
    network_configuration {
        subnets = [
            "${aws_default_subnet.default_subnet_a.id}", 
            "${aws_default_subnet.default_subnet_b.id}", 
            "${aws_default_subnet.default_subnet_c.id}"
        ]
        security_groups = [
            "${aws_security_group.load_balancer_security_group.id}",
            "${aws_security_group.markdown_server_security_group.id}"
        ]
        assign_public_ip = true
    }
}
