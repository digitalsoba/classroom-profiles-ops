---
title: "Drone"
date: 2019-01-04T10:08:02-08:00
draft: false
---
# How to use and deploy Drone CICD
Drone is an open source CI/CD tools that uses docker container for pipelines. It's fast and highly configurable

Drone requirements:
 - Docker
 - Docker-compose
 - Github OAuth access

## Create an OAuth App
On Github, navigate to your `Settings --> Developer Settings --> OAuth Apps`. Create a new OAuth app. For both URLs we are using HTTPS because we will generate a Cert with Let’s Encrypt when drone is deployed.

Inputs
 - Application name: Anything you want
 - Homepage URL: https://drone.example.com
 - Application description - Optional
 - Authorization callback URL - https://drone.example.com/login

After you created your app you should be welcomed with a page that contains Client ID and Client Secret, make sure you save this.

## Creating the docker-compose.yml file
Drone runs purely in containers, in our example we're going use a single machine. We can further expand drone to use additional agents to increase task capacity. We will need two files created: `docker-compose.yml` and a `.env` file. 

### docker-compose.yml
```yml
version: '3'

services:
  drone:
    container_name: drone
    image: 'drone/drone:1.0.0-rc.1'
    restart: always
    ports:
        - '80:80'
        - '443:443'
    volumes:
        - '/var/run/docker.sock:/var/run/docker.sock'
        - '/var/lib/drone:/data'
    environment:
        - DRONE_GITHUB_SERVER=https://github.com
        - DRONE_GITHUB_CLIENT_ID=$CLIENT_ID
        - DRONE_GITHUB_CLIENT_SECRET=$CLIENT_SECRET
        - DRONE_RUNNER_CAPACITY=2
        - DRONE_SERVER_HOST=$SERVER_HOST
        - DRONE_SERVER_PROTO=https
        - DRONE_TLS_AUTOCERT=true
        - DRONE_USER_FILTER=$ORG, $USER
        - DRONE_USER_CREATE=username:$USER,machine:false,admin:true
```

### .env
```bash
# Grab these from the OAuth app
$CLIENT_ID=pastefromgithub
$CLIENT_SECRET=pastefromgithub

# This will be host where drone is installed
$SERVER_HOST=drone.example.com

# This can be a github user or a machine user
$USER=user
$ORG=githuborganization
```

## Transfering yaml file
There are multiple ways to deploy drone, one method is using the ansible playbook. This playbook will also install docker and docker compose. Another option is to rsync or create the docker-compose.yml file and .env file. After, run `docker-compose up -d `.

### Using the ansible playbook
Make sure you have ansible installed on your master machine and python/python3. Create an .env file in the `docker/drone` directory with the required environment variables. Switch to the `ansible/playbooks/drone` directory. Create a `hosts.ini` file and specify your host and username; also use python3 as a python interpreter. An example below

```ini
[drone]
drone.example.com

[drone:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=user
```
Run `ansible-playbook --ask-vault-pass drone.yml` to deploy.