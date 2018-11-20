### Variables ###
variable "rds-name" {
  description = "name of RDS instance you want to create"
}

variable "password" {
  description = "Password to the instance"
}

variable "user" {
  description = "Name of master user on RDS instance"
}

variable "instance-class" {
  description = "instance type the RDS will have"
}

variable "multi-zone" {
  description = "boolean, will the RDS use multi-az?"
}

variable "subnet-name" {
  description = "name of the subnet group"
}

variable "security-group" {
  description = "security group that rds will use"
}

variable "port-number" {
  description = "port number for rds to use"
}

variable "engine" {
  description = "database engine, usually mysql"
  default     = "mysql"
}

variable "engine-version" {
  description = "database version to use"
  default     = "5.6.41"
}

variable "storage" {
  description = "Type of storage, RDS will have"
  default     = "standard"
}

variable "parameter-name" {
  description = "name of the parameter group name"
  default     = "default.mysql5.6"
}

variable "public-access" {
  description = "boolean value, will rds have public access"
}

variable "skip-snapshot" {
  description = "boolean value, should skip final snapshot creation when deleted"
  default     = "false"
}

variable "final-snapshot" {
  description = "identifier for the final snapshot created"
}

variable "backup-period" {
  description = "How long the snapshots will live in days"
  default     = "10"
}

variable "storage-encryption" {
  description = "boolen value, will the RDS instance be encrypted"
  default     = "false"
}

#### RDS Instance ####
resource "aws_db_instance" "mysql" {
  allocated_storage         = 10
  engine                    = "${var.engine}"
  engine_version            = "${var.engine-version}"
  instance_class            = "${var.instance-class}"
  identifier                = "${var.rds-name}"
  multi_az                  = "${var.multi-zone}"
  port                      = "${var.port-number}"
  username                  = "${var.user}"
  password                  = "${var.password}"
  db_subnet_group_name      = "${var.subnet-name}"
  parameter_group_name      = "${var.parameter-name}"
  vpc_security_group_ids    = ["${var.security-group}"]
  publicly_accessible       = "${var.public-access}"
  skip_final_snapshot       = "${var.skip-snapshot}"
  final_snapshot_identifier = "${var.final-snapshot}"
  backup_window             = "02:00-02:30"
  backup_retention_period   = "${var.backup-period}"
  storage_encrypted         = "${var.storage-encryption}"

  tags {
    Name = "rds = ${var.rds-name}"
  }
}