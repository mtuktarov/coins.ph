# How-to
1. Install ```helm``` on your local machine
2. Init it :

```
$ helm init
$ kubectl create serviceaccount --namespace kube-system tiller
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

3. Deploy metallb that will be used as loadbalancer


```
$ helm install --name metallb --namespace metallb-system --set rbac.create=true --set existingConfigMap=config stable/metallb
```

4. In ```metallb-config.yaml``` specify worker-node internal IP and apply the configruation map

```
$  kubectl apply --record -f metallb-config.yaml
```

5. Install a namespace and ingress:

```
$ chmod +x install-ingress.sh 
$ ./install-ingress.sh test-web
```
6. Make sure that nginx-ingress-controller got the EXTERNAL-IP

```
mtuktarov-mbp:kuber mtuktarov$ k get svc -n test-web 
NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                      AGE
nginx-ingress-controller        LoadBalancer   10.103.222.110   10.211.55.15   80:30651/TCP,443:30997/TCP   92s
nginx-ingress-default-backend   ClusterIP      10.106.87.160    <none>         80/TCP                       92s
```

5. Deploy applciation:

```
$ chmod +x install.sh 
$ ./install.sh test-web
```

6. That's it. App should be accessible using loadbalancer external IP
