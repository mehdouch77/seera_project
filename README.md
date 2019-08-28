# seera_project


# Introduction
With this project you can deploy an automated wordpress stack with RDS on AWS cloud

# Prerequisites Details
To be able to deploy this stack you must have :

* Access to an AWS account: EC2,VPC,RDS,CloudWatch
* Terraform and Ansible installed

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

3. You can see that ansible inventory has been generated dynamically to **playbooks/inventory/seera**

# Deploy the wordpress stack with Ansible

1. Launch the playbook to deploy the stack:

`$ ansible-playbook -i inventory/all wordpress_deploy.yml`

2. Wordpress should be available within few minutes by visting http://server_ip.