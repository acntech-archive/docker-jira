# docker-jira: A Docker image for Jira Software (Agile)

## Features
* Installs *Altassian JIRA Software* v 7.1.9
* Runs on *Oracle Java* 8.
* Ready to be configured with *Nginx* as a reverse proxy (https available).

## Usage

```bash
docker run -d -p 8080:8080 acntech/adop-jira
```

### Parameters

You can use this parameters to configure your jira instance:

* **-s:** Enables the connector security and sets `https` as connector scheme.
* **-n &lt;proxyName&gt;:** Sets the connector proxy name.
* **-p &lt;proxyPort&gt;:** Sets the connector proxy port.
* **-c &lt;contextPath&gt;:** Sets the context path (do not write the initial /).

This parameters should be given to the entrypoint (passing them after the image):

```bash
docker run -d -p 8080:8080 acntech/adop-jira <parameters>
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
docker run -d -p 8080:8080 acntech/adop-jira -s -n example.com -p 443 -c jira
```

### Persistent data

The jira home is set to `/var/atlassian/jira` and installation to `/opt/atlassian/jira`. If you want to persist your data you should use a data volume for `/var/atlassian/jira`.

#### Binding a host directory

```bash
docker run -d -p 8080:8080 -v /home/user/jira-data:/var/atlassian/jira acntech/adop-jira
```

Make sure that the jira user (with id 547) has read/write/execute permissions.

If security is important follow the Atlassian recommendation:

> Ensure that only the user running Jira can access the Jira home directory, and that this user has read, write and execute permissions, by setting file system permissions appropriately for your operating system.


## License

This image is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.
