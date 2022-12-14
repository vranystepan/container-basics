## Ingress

You already know that Services are mainly used for inter-service
communication. Ingress's role is a bit different, it's responsible
for routing of the external traffic.

It's fair to say that vanilla Kubernetes can't handle this resource.
It requires some controller that handles these resources and creates
the specific route. In this lab we'll be using Nginx ingress controller
which is the most popular community project for this purpose. 

But it's not the only project. The true beauty of Ingresses is
the interoperability. Same Ingress resource will work even with
other controllers.

In this demo we're gonna use Nginx ingress controller. This open source
project is widely used by the whole Kubernetes community so you can
find really handy tutorials all over the internet.

----

1. make sure you're in the correct namespace [link](./00_single_pod.md)

2. create a local file with the following contents, please replace `<your namespace>` with the actual name of your namespace.


    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: app
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-prod
    spec:
      ingressClassName: nginx
      tls:
      - hosts:
        - <your namespace>.workshop.stepanvrany.cz
        secretName: training-tls
      rules:
      - host: <your namespace>.workshop.stepanvrany.cz
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app
                port:
                  number: 80
    ```

    > Please note the backend configuration. This is the upstream service we're gonna
    > route traffic to.

3. list ingress objects in your namespace

    ```bash
    kubectl get ing
    kubectl describe ing app
    ```

4. try to reach your app directly from your workstation, please replace `<your namespace>` with the actual name of your namespace.

    ```bash
    curl https://<your namespace>.workshop.stepanvrany.cz
    ```

    or

    ```powershell
    Invoke-WebRequest https://<your namespace>.workshop.stepanvrany.cz
    ```

5. add following annotation to the ingress object and send a new request to the service

    ```yaml
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "Request-Id: $req_id";
    ```

6. view the logs of your app

    ```bash
    kubectl logs deploy/app
    ```

7. check other [interesting annotations](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) in the official documentation

8. instructor will show you the assembled configuration in the ingress controller containers.

9. proceed to the [next section](./06_configuration.md)