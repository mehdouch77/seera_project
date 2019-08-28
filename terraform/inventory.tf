data "template_file" "inventory" {
    template = "${file("inventory.tpl")}"

    vars = {
        public_ip = "${aws_instance.wordpress_stack_server.public_ip}"
        db_address = "${aws_db_instance.wordpress_rds_instance.address}"
    }
}

resource "null_resource" "update_inventory" {

    triggers = {
        template = "${data.template_file.inventory.rendered}"
    }

    provisioner "local-exec" {
        command = "echo '${data.template_file.inventory.rendered}' > ../playbooks/inventory/seera"
    }
}