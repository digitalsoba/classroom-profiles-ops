# Ops repo for senior design
[![Build Status](https://cloud.drone.io/api/badges/digitalsoba/classroom-profiles-ops/status.svg)](https://cloud.drone.io/digitalsoba/classroom-profiles-ops)

Welcome to the infrastructure repo for my senior design project. Terraform is used to create resources in AWS, Ansible is used to configure them. Documentation available on the [wiki](https://github.com/digitalsoba/classroom-profiles-ops/wiki)

## AWS Resources with Terraform
- S3 Backend
- S3 buckets
- VPC
- RDS
- EC2 + EC2 Spot Instances
- IAM
- Lightsail
- ECS + ECR + ALB

## Ansible playbooks
- Install Grafana + Prometheus monitoring stack
- Install ELK monitoring stack + Filebeat
- Install Drone CI
- Install Laravel + Deploy classroom profiles project
- Various roles for automation