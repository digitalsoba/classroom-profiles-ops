# Elastic stack (ELK) on Docker
[![Elastic Stack version](https://img.shields.io/badge/ELK-6.4.1-blue.svg?style=flat)](https://github.com/deviantony/docker-elk/issues/312)
[![Build Status](https://travis-ci.org/digitalsoba/docker-elk.svg?branch=master)](https://travis-ci.org/digitalsoba/docker-elk)

This is a fork from [deviantony](https://github.com/deviantony/docker-elk)
Run the latest version of the [Elastic stack](https://www.elastic.co/elk-stack) with Docker and Docker Compose.

It will give you the ability to analyze any data set by using the searching/aggregation capabilities of Elasticsearch
and the visualization power of Kibana.

Based on the official Docker images from Elastic and Nginx-Alpine:

* [elasticsearch](https://github.com/elastic/elasticsearch-docker)
* [logstash](https://github.com/elastic/logstash-docker)
* [kibana](https://github.com/elastic/kibana-docker)
* [nginx](https://hub.docker.com/_/nginx/): Nginx used as a reverse proxy for Kibana

**Note**: Other branches in this project are available:

* [`x-pack`](https://github.com/deviantony/docker-elk/tree/x-pack): X-Pack support
* [`searchguard`](https://github.com/deviantony/docker-elk/tree/searchguard): Search Guard support
* [`vagrant`](https://github.com/deviantony/docker-elk/tree/vagrant): run Docker inside Vagrant


## Contents

- [Elastic stack (ELK) on Docker](#elastic-stack-elk-on-docker)
  - [Contents](#contents)
  - [Requirements](#requirements)
    - [Host setup](#host-setup)
    - [SELinux](#selinux)
    - [Docker for Windows](#docker-for-windows)
  - [Usage](#usage)
    - [Bringing up the stack](#bringing-up-the-stack)
  - [Initial setup](#initial-setup)
    - [Default Kibana index pattern creation](#default-kibana-index-pattern-creation)
      - [Via the Kibana web UI](#via-the-kibana-web-ui)
  - [Configuration](#configuration)
    - [How can I tune the Kibana configuration?](#how-can-i-tune-the-kibana-configuration)
    - [How can I tune the Logstash configuration?](#how-can-i-tune-the-logstash-configuration)
    - [How can I tune the Elasticsearch configuration?](#how-can-i-tune-the-elasticsearch-configuration)
    - [How can I scale out the Elasticsearch cluster?](#how-can-i-scale-out-the-elasticsearch-cluster)
  - [Storage](#storage)
    - [How can I persist Elasticsearch data?](#how-can-i-persist-elasticsearch-data)
  - [Extensibility](#extensibility)
    - [How can I add plugins?](#how-can-i-add-plugins)
    - [How can I enable the provided extensions?](#how-can-i-enable-the-provided-extensions)
  - [JVM tuning](#jvm-tuning)
    - [How can I specify the amount of memory used by a service?](#how-can-i-specify-the-amount-of-memory-used-by-a-service)
    - [How can I enable a remote JMX connection to a service?](#how-can-i-enable-a-remote-jmx-connection-to-a-service)
  - [Going further](#going-further)
    - [Using a newer stack version](#using-a-newer-stack-version)
    - [Plugins and integrations](#plugins-and-integrations)

## Requirements

### Host setup

1. Install [Docker](https://www.docker.com/community-edition#/download) version **17.05+**
2. Install [Docker Compose](https://docs.docker.com/compose/install/) version **1.6.0+**
3. Clone this repository

### SELinux

On distributions which have SELinux enabled out-of-the-box you will need to either re-context the files or set SELinux
into Permissive mode in order for docker-elk to start properly. For example on Redhat and CentOS, the following will
apply the proper context:

```console
$ chcon -R system_u:object_r:admin_home_t:s0 docker-elk/
```

### Docker for Windows

If you're using Docker for Windows, ensure the "Shared Drives" feature is enabled for the `C:` drive (Docker for Windows > Settings > Shared Drives). See [Configuring Docker for Windows Shared Drives](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/) (MSDN Blog).

## Usage

### Bringing up the stack

**Note**: In case you switched branch or updated a base image - you may need to run `docker-compose build` first

Make sure you have the `.env` file. For now, all we have inside the file is `ELK_VERSION=6.4.1`. Change this to the repsective version you would like to use. Also create a `htpasswd.users` file in the `nginx` directory. Nginx will read this file to allow authentication to Kibana. 

If you want to generate an htaccess file you can run the `create-htaccess.sh` script with the user an as argument.
```bash
./create-htaccess.sh $USER
```

Start the stack using `docker-compose`:

```console
$ docker-compose up -d
```

Give Kibana a few seconds to initialize, then access the Kibana web UI by hitting
[http://localhost](http://localhost) with a web browser, or to whatever your set for the nginx serverblock.

By default, the stack exposes the following ports:
* 5044: Logstash TCP input.
* 9200: Elasticsearch HTTP
* 9300: Elasticsearch TCP transport
* 80: Kibana - This is reverse proxied from the internal port 5601


```console
$ nc localhost 5044 < /path/to/logfile.log
```

## Initial setup

### Default Kibana index pattern creation

When Kibana launches for the first time, it is not configured with any index pattern.

#### Via the Kibana web UI

**NOTE**: You need to inject data into Logstash before being able to configure a Logstash index pattern via the Kibana web
UI. Then all you have to do is hit the *Create* button.

Refer to [Connect Kibana with
Elasticsearch](https://www.elastic.co/guide/en/kibana/current/connect-to-elasticsearch.html) for detailed instructions
about the index pattern configuration.

## Configuration

**NOTE**: Configuration is not dynamically reloaded, you will need to restart the stack after any change in the
configuration of a component.

### How can I tune the Kibana configuration?

The Kibana default configuration is stored in `kibana/config/kibana.yml`.

It is also possible to map the entire `config` directory instead of a single file.

### How can I tune the Logstash configuration?

The Logstash configuration is stored in `logstash/config/logstash.yml`.

It is also possible to map the entire `config` directory instead of a single file, however you must be aware that
Logstash will be expecting a
[`log4j2.properties`](https://github.com/elastic/logstash-docker/tree/master/build/logstash/config) file for its own
logging.

### How can I tune the Elasticsearch configuration?

The Elasticsearch configuration is stored in `elasticsearch/config/elasticsearch.yml`.

You can also specify the options you want to override directly via environment variables:

```yml
elasticsearch:

  environment:
    network.host: "_non_loopback_"
    cluster.name: "my-cluster"
```

### How can I scale out the Elasticsearch cluster?

Follow the instructions from the Wiki: [Scaling out
Elasticsearch](https://github.com/deviantony/docker-elk/wiki/Elasticsearch-cluster)

## Storage

### How can I persist Elasticsearch data?

The data stored in Elasticsearch will be persisted after container reboot but not after container removal.

In order to persist Elasticsearch data even after removing the Elasticsearch container, you'll have to mount a volume on
your Docker host. Update the `elasticsearch` service declaration to:

```yml
elasticsearch:

  volumes:
    - /path/to/storage:/usr/share/elasticsearch/data
```

This will store Elasticsearch data inside `/path/to/storage`.

**NOTE:** beware of these OS-specific considerations:
* **Linux:** the [unprivileged `elasticsearch` user][esuser] is used within the Elasticsearch image, therefore the
  mounted data directory must be owned by the uid `1000`.
* **macOS:** the default Docker for Mac configuration allows mounting files from `/Users/`, `/Volumes/`, `/private/`,
  and `/tmp` exclusively. Follow the instructions from the [documentation][macmounts] to add more locations.

[esuser]: https://github.com/elastic/elasticsearch-docker/blob/016bcc9db1dd97ecd0ff60c1290e7fa9142f8ddd/templates/Dockerfile.j2#L22
[macmounts]: https://docs.docker.com/docker-for-mac/osxfs/

## Extensibility

### How can I add plugins?

To add plugins to any ELK component you have to:

1. Add a `RUN` statement to the corresponding `Dockerfile` (eg. `RUN logstash-plugin install logstash-filter-json`)
2. Add the associated plugin code configuration to the service configuration (eg. Logstash input/output)
3. Rebuild the images using the `docker-compose build` command

### How can I enable the provided extensions?

A few extensions are available inside the [`extensions`](extensions) directory. These extensions provide features which
are not part of the standard Elastic stack, but can be used to enrich it with extra integrations.

The documentation for these extensions is provided inside each individual subdirectory, on a per-extension basis. Some
of them require manual changes to the default ELK configuration.

## JVM tuning

### How can I specify the amount of memory used by a service?

By default, both Elasticsearch and Logstash start with [1/4 of the total host
memory](https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/parallel.html#default_heap_size) allocated to
the JVM Heap Size.

The startup scripts for Elasticsearch and Logstash can append extra JVM options from the value of an environment
variable, allowing the user to adjust the amount of memory that can be used by each component:

| Service       | Environment variable |
|---------------|----------------------|
| Elasticsearch | ES_JAVA_OPTS         |
| Logstash      | LS_JAVA_OPTS         |

To accomodate environments where memory is scarce (Docker for Mac has only 2 GB available by default), the Heap Size
allocation is capped by default to 256MB per service in the `docker-compose.yml` file. If you want to override the
default JVM configuration, edit the matching environment variable(s) in the `docker-compose.yml` file.

For example, to increase the maximum JVM Heap Size for Logstash:

```yml
logstash:

  environment:
    LS_JAVA_OPTS: "-Xmx1g -Xms1g"
```

### How can I enable a remote JMX connection to a service?

As for the Java Heap memory (see above), you can specify JVM options to enable JMX and map the JMX port on the Docker
host.

Update the `{ES,LS}_JAVA_OPTS` environment variable with the following content (I've mapped the JMX service on the port
18080, you can change that). Do not forget to update the `-Djava.rmi.server.hostname` option with the IP address of your
Docker host (replace **DOCKER_HOST_IP**):

```yml
logstash:

  environment:
    LS_JAVA_OPTS: "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=18080 -Dcom.sun.management.jmxremote.rmi.port=18080 -Djava.rmi.server.hostname=DOCKER_HOST_IP -Dcom.sun.management.jmxremote.local.only=false"
```

## Going further

### Using a newer stack version

To use a different Elastic Stack version than the one currently available in the repository, simply change the version
number inside the `.env` file, and rebuild the stack with:

```console
$ docker-compose build
$ docker-compose up
```

**NOTE**: Always pay attention to the [upgrade instructions](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-upgrade.html)
for each individual component before performing a stack upgrade.

### Plugins and integrations

See the following Wiki pages:

* [External applications](https://github.com/deviantony/docker-elk/wiki/External-applications)
* [Popular integrations](https://github.com/deviantony/docker-elk/wiki/Popular-integrations)
