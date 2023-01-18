// Create a load balancer that will be used to route traffic to the markdown server.
resource "aws_alb" "server_load_balancer" {
    name = "${var.project_name}-load-balancer"
    load_balancer_type = "application"

    subnets = [
        "${aws_default_subnet.default_subnet_a.id}", 
        "${aws_default_subnet.default_subnet_b.id}", 
        "${aws_default_subnet.default_subnet_c.id}"
    ]

    // This security group defines the network ingress/egress for the load balancer.
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

// Allow inbound traffic at port 80 (for the load balancer), and let it
// communicate with the markdown server instances.
resource "aws_security_group" "load_balancer_security_group" {
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// Allow the markdown_server instances to be freely able to communicate with anything
// since they're only really allowed access by the load balancer.
resource "aws_security_group" "server_security_group" {
    name = "${var.project_name}-security-group"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        // Ensure anything that talks to the markdown-server is itself in the same security group
        // as the load balancer.
        security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// Create a target group of servers that the load balancer can point to.
resource "aws_lb_target_group" "server_target_group" {
    name = "${var.project_name}-target-group"
    // The load balancer that this target group will be associated with.
    // This is a dependency because the target group can't be created until the load balancer
    // has been created.
    depends_on = [
      aws_alb.server_load_balancer
    ]

    // The port that the targets (i.e. server instances) will receive traffic on.
    // :sus: that they're required with `target_type = "ip"` but our servers
    // are actually running on port 9003.
    // meh. it works as is, why break it.
    port = 80
    protocol = "HTTP"
    target_type = "ip"

    vpc_id = "${aws_default_vpc.default_vpc.id}"

    // This is how the server instances report they are healthy.
    health_check {
        path = var.healthcheck_path
        interval = 15
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
        port = var.healthcheck_port
        matcher = "200,301,302"
    }
}

// Create a listener that will listen for traffic on port 80 and forward it to the target group.
resource "aws_lb_listener" "server_listener" {
    load_balancer_arn = "${aws_alb.server_load_balancer.arn}"
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.server_target_group.arn}"
    }
}