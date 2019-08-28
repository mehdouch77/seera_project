output "wordpress_server_ip" {
  value = "${aws_instance.wordpress_stack_server.public_ip}"
}

output "rds_instance_db_endpoint" {
  value = "${aws_db_instance.wordpress_rds_instance.endpoint}"
}