---
title: "Elastic Stack"
date: 2019-01-03T11:00:49-08:00
draft: false
---
## Intro

The Elastic stack or ELK (Old nickname) is an open source set of tools that allow us to gather logs and metrics to visualize them in real-time. The main components of the include: Elasticsearch, Logstash, and Kibana. Elastic Search allows us to search, analyze, and store data. Logstash aggregates data into Elasticsearch. Kibana let's use visualize our data. The stack also includes beats which are lightweight data shippers that point to either Elasticsearch or Logstash. For our stack, we also added Nginx as a reverse proxy for Kibana. The basic flow of information looks like this (Source: [Digitalocean](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-14-04)):
![elk-stack-diagram](https://assets.digitalocean.com/articles/elk/elk-infrastructure.png)

## Prerequisites 
- Ansible 
- SSH access to the ELK server 

### Install ELK stack master playbook
Clone the ops repo if you haven't already with `git clone <insert project>` and change directory into the project. Change directory into the playbook with `cd ansible/playbooks/elk`. We need to add our host files to run the playbook against. Create a `host.ini` file with your favorite text editor ex. `vim hosts.ini`. Add your hosts with the following variables like the sample below:
```ini
[elk]
example.com

[elk:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_user=user
```
Now run the playbook with `ansible-playbook elk.yml` This playbook will run the roles: `elk and elk-load` which will install the Elastic stack and load the Filebeat dashboards into the server. After installing the master node verify the services are up by visiting the elk server on your web browser. If the stack is not up check the server to see if the ELK services are up and check the logs. If everything is running you can move on to configuring Kibana and installing beats on your server nodes.

### Configuring Kibana
In Kibana set the default index pattern to `Filebeat-*`. Visit the Kibana page, navigate to `Management-->Kibana-->Index Patterns`. Select `Filebeat-*` on the left hand side, the page will load the index patterns; select the star on the right hand side to set Filebeat-* as the default index. 

### Install beats into nodes
Filebeat ships log data into the master elk server. This playbook is located in `ansible/playbooks/elk-beats`. Change directory into this folder. Create a host inventory file and add your configurations ex. `vim hosts.ini`. This playbook installs beats on debian and redhat hosts. It also allows both python2 and python3 as the python interpreters. 

```ini
[elk-beats]
example1.com
example2.com

[python2]
example3.com

[elk-beats:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_user=user

[python2:vars]
ansible_ssh_user=user
```

When ready to deploy run `ansible-playbook elk-beats`. After the playbook completes, verify beats are being shipped by visiting Kibana's discovery tab. 

## Ansible playbook explanation

### ELK playbook and roles
The playbook is found in the ops repo for the project in the **ansible/playbook/elk** directory. This contains **ansible.cfg**, **elk.yml**, and **hosts.ini** after the inventory is created. 

- **ansible.cfg** - Contains the path for roles and hosts inventory 
- **elk.yml** - This is the main playbook that use the elk and elk load roles
- **hosts.ini** - Inventory of hosts to run the playbook against

#### Roles
There are two main roles and a few important directories: 

- **elk** - Installs Java, adds Elastic repo, installs ELK services and Nginx proxy
  - **vars** - Contains variable for ELK host, **edit this**
  - **templates** - Contains Logstash pipelines configs.
- **elk-load** - Installs Filebeat and loads index patterns and sample dashboards

### ELK-Beats playbook and roles
Located in **ansible/playbook/elk-beats**, this playbook will install Filebeat into the node servers with the **systems, apache, and Nginx** modules enabled.

#### Roles
There's only one role

- **elk-beats** - Installs Filebeat service for debian and redhat based distros. Starts and enables the service. 
  - **vars** - Contains variable for ELK host, **edit this**

### Things to consider
- Add SSL cert on Nginx Proxy
  
### Issues
