```
namespace=blogd
```

```
k apply -f <(echo "
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace")
```

```
kubectl --namespace $namespace create secret tls tls-secret --key $django_ssl_key_path --cert $django_ssl_cert_path
kubectl create secret docker-registry regcred --docker-username=$django_kuber_docker_reg_user --docker-password=$django_kuber_docker_reg_pass --namespace $namespace
```


```
helm repo add funkypenguin https://funkypenguin.github.io/helm-charts
```

```
helm install local-volume-provisioner \
--set classes[0].name=local-storage \
--set classes[0].hostDir=/mnt/disks \
--set classes[0].storageClass=true \
--set common.namespace=kube-system \
--namespace kube-system \
funkypenguin/local-volume-provisioner
```


```
helm install postgresql \
--set postgresqlUsername=$django_kuber_postgresql_user \
--set postgresqlPassword=$django_kuber_postgresql_pass \
--set postgresqlDatabase=blogd \
--set persistence.size=1Gi \
--set persistence.storageClass=local-storage \
--namespace $namespace \
stable/postgresql
```


```
helm install blogd \
--set django.db.host=postgresql \
--set django.db.name=blogd \
--set django.db.user=$django_kuber_postgresql_user \
--set django.db.password=$django_kuber_postgresql_pass \
--set django.db.automaticMigrations=true \
--set django.superuser.password=$django_kuber_superuser_pass \
--set django.smtp_email.host=smtp.yandex.ru \
--set django.smtp_email.port=465 \
--set django.smtp_email.user=$django_kuber_smtp_email_user \
--set django.smtp_email.password=$django_kuber_smtp_email_pass \
--set django.siteDomainName=mtuktarov.com \
--set ingress.enabled=true \
--set ingress.tls[0].secretName=tls-secret \
--set ingress.tls[0].hosts[0]=mtuktarov.com \
--set ingress.hosts[0].host=mtuktarov.com \
--set ingress.hosts[0].paths[0]='/' \
--namespace $namespace \
./blogd
```


```
helm install ingress \
--set name=ingress \
--set default-ssl-certificate=tls-secret \
--set controller.service.externalTrafficPolicy=Local \
--set controller.service.type=NodePort \
--set controller.ingressClass=nginx \
--set controller.extraArgs.configmap=kube-system/nginx-ingress-controller \
--set controller.service.nodePorts.https=32443 \
--set controller.service.nodePorts.http=32080 \
--namespace kube-system \
stable/nginx-ingress
```
