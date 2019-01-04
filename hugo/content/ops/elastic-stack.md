---
title: "Elastic Stack"
date: 2019-01-03T11:00:49-08:00
draft: false
---
## Intro

The Elastic stack or ELK (Old nickname) is an open source set of tools that allow us to gather logs and metrics and visualize them. The main components of the include: Elasticsearch, Logstash, and Kibana. Elastic Search is used to search, analyze, and store data. Logstash aggregates data into Elasticsearch. Kibana let's use visualize our data. The stack also includes beats which are lightweight data shippers that point to either Elasticsearch or Logstash. For our stack, we also added Nginx as a reverse proxy for Kibana. The basic flow of information looks like this (Source: [Digitalocean](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-14-04)):
![elk-stack-diagram](https://assets.digitalocean.com/articles/elk/elk-infrastructure.png)

## Prerequisites 
- Ansible 
- SSH access to the servers you're running tha playbook against
  - Python2/3 

### Install ELK stack master playbook
Clone the ops repo if you haven't already and change directory into the project. 

`git clone <insert project>` 

`cd ansible/playbooks/elk`

We need to add hosts to run the playbook against. Create a `host.ini` file with your favorite text editor ex. 

`vim hosts.ini`. 

In the host inventory you will need: elk, beats, beats-python2:
```ini
# Master ELK server
[elk]
example.com

# Node servers
[beats]
example.com
2.example.com

# Nodes using python2
[beats-python2]
ssh.matabit.org

# Variables for hosts
[beats:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_user=user

[beats-python2:vars]
ansible_ssh_user=user

[elk:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_user=user

```
The master playbook is `elk.yml`. This playbook will install the Elastic stack and load the Filebeat dashboards into the server. To run the playbook:

`ansible-playbook elk.yml`

After installing the master node verify the services are up by visiting the elk server on your web browser. If the stack is not up check the server to see if the ELK services are up and visit the logs. If everything is running you can move on to configuring Kibana and installing beats on your server nodes. 


### Configuring Kibana
In Kibana set the default index pattern to `Filebeat-*`. Visit the Kibana page, navigate to `Management-->Kibana-->Index Patterns`. Select `Filebeat-*` on the left hand side, the page will load the index patterns; select the star on the right hand side to set Filebeat-* as the default index. 

### Install beats into nodes
Filebeat ships log data into the master elk server. This playbook is located in `ansible/playbooks/elk` under the filename `elk-beats.yml`. If you haven't already add hosts to into your inventory under beats and beats-python2.

When ready to deploy run 

`ansible-playbook elk-beats`

After the playbook completes, verify beats are being shipped by visiting Kibana's discovery tab. 


## Ansible playbook explanation

### Playbooks and roles
The playbooks are found in the ops repo for the project in the **ansible/playbook/elk** directory. This contains **ansible.cfg**, **elk.yml**, **elk-beats.yml** and **hosts.ini**.

- **ansible.cfg** - Contains the path for roles and hosts inventory 
- **elk.yml** - This is the main playbook that use the elk and elk load roles
- **elk-beats.yml** - Installs Filebeat and enables modules
- **hosts.ini** - Inventory of hosts to run the playbook against

#### Roles
**ELK playbook**: Installs ELK stack with Nginx Proxy

- **elk** - Installs Java, adds Elastic repo, installs ELK services and Nginx proxy
  - **vars** - Contains variable for ELK host, **edit this**
  - **templates** - Contains Logstash pipelines configs.
- **elk-load** - Installs Filebeat and loads index patterns and sample dashboards

**ELK-beats playbook**: this playbook will install Filebeat into the node servers with the **systems, apache, and Nginx** modules enabled.

- **elk-beats** - Installs Filebeat service for debian and redhat based distros. Starts and enables the service. 
  - **vars** - Contains variable for ELK host, **edit this**

### Things to consider
- Add SSL cert on Nginx Proxy
  
### Issues
