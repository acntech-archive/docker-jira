# docker-jira: A Docker image for Jira Software (Agile)

## Features
* Installs *Altassian JIRA Software* v 7.1.9
* Runs on *Oracle Java* 8.
* Ready to be configured with *Nginx* as a reverse proxy (https available).

## Quick Start
For the `JIRA_HOME` directory that is used to store the data we recommend mounting a host directory as a [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/) :
Set permissions for the data directory so that the runuser can write to it:
```bash
$> docker run -u root -v /data/jira:/var/atlassian/application-data/jira acntech/adop-jira chown -R daemon /var/atlassian/application-data/jira
```
Start Atlassian JIRA Software:

```bash
$> docker run -v /data/jira:/var/atlassian/application-data/jira --name="jira" -d -p 8080:8080 acntech/adop-jira
```
Success. JIRA Software is now available on http://localhost:8080*
Please ensure your container has the necessary resources allocated to it. We recommend 2GB of memory allocated. See [System Requirements](https://confluence.atlassian.com/adminjiraserver071/jira-applications-installation-requirements-802592164.html) for further information.
_* Note: If you are using docker-machine on Mac OS X, please use open http://$(docker-machine ip default):8080 instead._

### Parameters

You can use this parameters to configure your jira instance:

* **-s:** Enables the connector security and sets `https` as connector scheme.
* **-n &lt;proxyName&gt;:** Sets the connector proxy name.
* **-p &lt;proxyPort&gt;:** Sets the connector proxy port.
* **-c &lt;contextPath&gt;:** Sets the context path (do not write the initial /).

This parameters should be given to the entrypoint (passing them after the image):

```bash
$> docker run -d -p 8080:8080 acntech/adop-jira <parameters>
```

> If you want to execute another command instead of launching jira you should overwrite the entrypoint with `--entrypoint <command>` (docker run parameter).

### Nginx as reverse proxy

Lets say you have the following *nginx* configuration for jira:

```
server {
	listen                          80;
	server_name                     example.com;
	return                          301 https://$host$request_uri;
}
server {
	listen                          443;
	server_name                     example.com;

	ssl                             on;
	ssl_certificate                 /path/to/certificate.crt;
	ssl_certificate_key             /path/to/key.key;
	location /jira {
		proxy_set_header X-Forwarded-Host $host;
		proxy_set_header X-Forwarded-Server $host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass http://127.0.0.1:8080;
		proxy_redirect off;
	}
}
```

> This is only an example, please secure you *nginx* better.

For that configuration you should run your jira container with:

```bash
$> docker run -d -p 8080:8080 acntech/adop-jira -s -n example.com -p 443 -c jira
```


## Upgrade

To upgrade to a more recent version of JIRA Software you can simply stop the `jira`
container and start a new one based on a more recent image:

    $> docker stop jira
    $> docker rm jira
    $> docker run ... (See above)

As your data is stored in the data volume directory on the host it will still
be available after the upgrade.

_Note: Please make sure that you **don't** accidentally remove the `jira`
container and its volumes using the `-v` option._

## License

This image is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.
