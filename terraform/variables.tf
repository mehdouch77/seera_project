variable "aws_region" {
  description = "AWS Region"
  default = "us-west-2"
}
variable "vpc_cidr" {
    description = "CIDR for the VPC"
    default = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}

variable "rds_private_subnet_cidr" {
    description = "CIDR for the RDS Private Subnet"
    default = "10.0.2.0/24"
}
variable "deployer_public_key" {
    description = "The deployer SSH public Key"
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcOV8QxNd3/kS8uB7hWuweVkFI2Q7vrQM5fuccuj9xwTjp/WlPaPRLx80KH3fAMsIDjismvHqfWaCksP6n8R0cmcJSEPHiaPwI+JIZPPjzgZdTxEfoTRvBtAdxrk35JMVpVGLPwudW4WxL4cqZOaYPigPIdVjLILTCetmYz+Zlj9a1yoSCeo6wyjgrmeQDDKELrQDOUvUoqjdI0cg9hteTSvGsU3bjgMKF27yhONy8il4fvUkPxhjbp8wcELQML63weOqoKYCtK6X5c2+9Y761Q2URYux2YMIWYbo3H2BhXXGYCrFlhKb9sKnWRxs+Fuvx/pnVR82oHvdGX0qQimSh m.salmi@ejadtech.com.sa"
}

