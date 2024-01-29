### Install k8s cluster using kind

```
kind create cluster --config=demo-cluster.yml
```

### Istio Installation

<https://istio.io/latest/docs/setup/install/>

### Add the helm istio repo

```
helm repo add istio <https://istio-release.storage.googleapis.com/charts>

```

### View the default values (Optional)

```
helm show values istio/base > helm-default/istio-base-default.yml
helm show values istio/istiod > helm-default/istiod-default.yml
helm show values istio/gateway > helm-default/istio-gateway-default.yml

```

> Istio Base: Install the Istio base chart which contains cluster-wide Custom Resource Definitions (CRDs) which must be installed prior to the deployment of the Istio control plane

### Install istio in the kind cluster using terraform

```
cd istio-terraform
terraform apply

```

> Validate the istio CRD's created Validate if istiod is running Validate if ingress-gateway is created

### Apply the patch to change service type of LoadBalancer to Nodeport

```
k patch service gateway -n istio-ingress --patch "$(cat patch-ingressgateway-nodeport.yaml)"\\n

```

### Canary Example

```
cd examples/1-example
k apply -f 0-namespace.yml
k apply -f 1-deployment-v1.yml
k apply -f 2-deployment-v2.yml
k apply -f 3-myapp-service.yml
k apply -f 4-destination-rule.yml
k apply -f 5-virtual-service.yml
k apply -f 6-gateway.yml

```

- Hit the app and test the results
```
while true; do curl -s http://demo.localhost/ | grep background-color; sleep 1; done;
```

> Now, do a port forward to the svc and hit the app. What did you infer from the result?

### Allow only encrypted connection between services

- Create  namespaces
```
d examples/2-example
kubectl apply -f 0-dev.yml
kubectl apply -f 1-stage.yml
```

-   Create a deployment for Nginx in the stage-ns namespace

```
kubectl create deployment nginx-deployment --image=nginx -n stage-ns

```

-   Expose the deployment as a service

```
kubectl expose deployment nginx-deployment --port=80 --type=ClusterIP -n stage-ns

```

-   Run a pod by disabling istio in dev-ns (one liner)

```
kubectl run busybox -n dev-ns --image=busybox --restart=Never --overrides='{"metadata": {"annotations": {"[sidecar.istio.io/inject](<http://sidecar.istio.io/inject>)": "false"}}}' -- sleep 3600

```

-   Test accessing the nginx service from dev-ns

```
k exec -it busybox -- wget -O- [<http://nginx-deployment.stage-ns.svc.cluster.local>](<http://nginx-deployment.stage-ns.svc.cluster.local/>)

```

### Enable peer authentication and only allow mtls communcation in stage-ns

```
k apply -f peerauthentication.yml

```

> Now try accessing the endpoint from dev-ns. Does it work?

### Demo to explain restricting access between ns, service etc.

- Create a namespace
```
kubectl apply -f 2-prod.yml
```

-   Create a deployment for Nginx in the stage-ns namespace

```
kubectl create deployment nginx-deployment --image=nginx -n stage-ns

```

-   Expose the deployment as a service

```
kubectl expose deployment nginx-deployment --port=80 --type=ClusterIP -n stage-ns

```

- Create an authorization policy in prod-ns to allow access only from stage-ns 

```
kubectl apply -f allow-prod-access.yml
```


> Now try access the nginx-deployment service in prod from stage-ns and dev-ns. What did you infer?

