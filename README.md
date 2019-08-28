# seera_project


# Introduction
With this project you can deploy and automated wordpress stack with RDS as a DB on AWS cloud

# Prerequisites Details
To be able to deploy this stack you must have :

* Access to an AWS account: EC2,VPC,RDS,CloudWatch
* Terraform and Ansible istalled

# Deploy Infrastucture

1. Add your public key in this field in the **terraform/variables.tf** file:

```
variable "deployer_public_key" {
    description = "The deployer SSH public Key"
    default = "public_key_value"
}
```

2. Initialise terraform workspace and create resources:
```
 $ terraform init
 $ terraform apply
```

3. You can get the wordpress server IP and the RDS endpoint from the AWS console

# Deploy the wordpress stack with Ansible

1. Add the wordpress ec2 instcance public ip in the **playbooks/inventory/all** file:

```
[web_servers]
 public_ip
```

2. Add the RDS endpoint in the **playbooks/roles/wordpress/defaults/main.yml** file:

`wp_db_host: terraform-20190827191028133700000001.cez5odjum6kw.us-west-2.rds.amazonaws.com`

3. Launch the playbook to deploy the stack:

`ansible-playbook -i inventory/all wordpress_deploy.yml`