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
        - <your namespace>.s02.training.eks.rocks
        secretName: training-tls
      rules:
      - host: <your namespace>.s02.training.eks.rocks
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

3. list ingress objects in your namespace

    ```bash
    kubectl get ing
    kubectl describe ing app
    ```

4. try to reach your app directly from your workstation, please replace `<your namespace>` with the actual name of your namespace.

    ```bash
    curl https://<your namespace>.s02.training.eks.rocks -H 'User-Agent: workstation'
    ```

    or

    ```powershell
    Invoke-WebRequest -Headers @{"User-Agent" = "workstation"} https://<your namespace>.s02.training.eks.rocks
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
