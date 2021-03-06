#Generate the userdata script, this is what joins the nodes to the ECS cluster
data "template_file" "userdata" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    region       = "${var.region}"
    cluster_name = "ecs-${var.env}-${var.region}"

    //consul_dns   = "${var.consul_elb_address}"
  }
}

#Create the security group for network ingress/egress
resource "aws_security_group" "ecs_instance_security_group" {
  name        = "ecs-${var.env}-instance-sg"
  description = "Instance security group for ECS"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "vpc_ingress" {
  type = "ingress"
  from_port = 1
  to_port = 65535
  protocol = "TCP"
  cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  security_group_id = "${aws_security_group.ecs_instance_security_group.id}"
}

#Create the ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-${var.env}-${var.region}"
}
