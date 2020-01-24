So in this repo we have:
1. Vagrant configured to deploy kubernetes cluster (2 nodes) automatically on Mac via Parallels Desktop provider.
2. Terraform to do the same on Yandex Cloud.
3. Both run ansible playbooks upon finish.
4. After Ansible is run we have a cluster which has 2 nodes - master and slave
5. We use 3 helm charts:
    - local-volume-provisioner - for automatic pv provisioning
    - postgresql - db
    - nginx-ingress - for access over http
6. We also must install secret with docker credentials and a secret with SSL certificates.

7. The chart for application is located in kubernetes/blogd directory

To run django_todo I modified my exisitng web-site. All the changed performed are available here:
https://github.com/mtuktarov/mtuktarov.ru/pull/7

Dockerfile is also located in this repo: https://github.com/mtuktarov/mtuktarov.ru/blob/django-todo/Dockerfile
Note: you must use 'django-todo' branch

8. Look at `kubernetes/README.md` for deploying examples

## About app

- I do not store any web-site files in container I run `git clone $branch` on a startup
- uwsgi container is sharing pod with nginx container
- for developing purposes you can run container with envvar `TEST_SERVER=true` and it will launch native django web server
- uwsgi outputs in the unix socket by default, uwsgi args can be changed using env var`UWSGI_PARAMS`

### HELM parameters

| Option  | Value |
|---------------|---------------|
| branch | branch or tag to checkout |
| imagePullSecrets  | list of docker secrets used to pull blogd image  |
| uwsgi_params      | uwsgi arguments. Use string format. |
| django.debug   | switch Django to debug mode|
| django.siteDomainName| site domain (for example - used when when generating links in emails)|

###  DB connections config

| Option  | Value |
|---------------|---------------|
| django.db.host | postgresql database host|
| django.db.name | postgresql database name|
| django.db.user | postgresql database user|
| django.db.password | postgresql database password|


### Actions that can be executed on the pod startup.

| Option                   | Meaning                                                              |
|--------------------------|----------------------------------------------------------------------|
| actions.wait_postgres     |  container will wait till postgres starts accepting requests         |
| actions.add_superuser     |  add superuser on the pod startup                                    |
| actions.configure_groups  |  create default groups and set read-only permissions for the models  |
| actions.rename_site       |  change default sites id 1 name example.com                          |
| actions.makemigrations    |  run ./manage.py makemigrations on the pod startup                   |
| actions.migrate           |  run ./manage.py migrate on the pod startup                          |
| actions.collect_static    |   run ./manage.py collectstatic --noinput on the pod startup         |
| actions.compress_static   |   run ./manage.py compress --force on the pod startup                |
| actions.disable_cache     |   run to disable memcached                                           |


###  Superuser credss for automatic creation

| Option        | Value |
|---------------|---------------|
| superuser.name|    name      |
| superuser.email|     email       |
| superuser.password|     password    |

###  smtp connection parameters

| Option              |          Value |
|----------------------------| ------------- |
| django.smtp_email.host     |   smtp host address  |
| django.smtp_email.port     |        port          |
| django.smtp_email.user     |     username         |
| django.smtp_email.password |     password        |

###


