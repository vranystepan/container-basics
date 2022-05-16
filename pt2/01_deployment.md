## Pods managed by Deployment object

Deployments are perhaps the most useful built-in workload-specific objects.
In everyday life, this is the synonym for running something in Kubernetes.
It is easy to configure, it works and there are really good examples
how to work with this object.

---

1. make sure you're in the correct namespace [link](./00_single_pod.md)

2. create a local file with the following contents:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app
      labels:
        app: app
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: app
      template:
        metadata:
          labels:
            app: app
        spec:
          containers:
            - name: app
              image: eu.gcr.io/revolgy-vaimo-edu/training/application:working
              ports:
                - containerPort: 8080
    ```

3. check all the pods

    ```bash
    kubectl get pods
    ```

4. and now - delete them. All.

    ```bash
    kubectl delete pod --all
    ```

5. list all the pods again

    ```bash
    kubectl get pods
    ```

6. and check the events

    ```bash
    kubectl get events
    ```

7. replicaset (managed by the Deployment) keeps pods in the desired count

8. if you want to see what's running there, you can simply forward container's port to your localhost

    ```bash
    kubectl port-forward deploy/app 8080:8080
    ```

    and from the different shell:

    ```
    curl localhost:8080
    ```

    or

    ```powershell
    Invoke-WebRequest http://localhost:8080
    ```

    > we'll try this in the next section even with different resources.


9. now let's try to add some init container. This init container will download some assets to the shared emptyDir volume. The same empty dir is shared with the application container.

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app
      labels:
        app: app
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: app
      template:
        metadata:
          labels:
            app: app
        spec:
          volumes:
            - name: assets
              emptyDir: {}
          initContainers:
            - name: download-assets
              image: eu.gcr.io/revolgy-vaimo-edu/training/application:working
              cmd:
                - sh
                - -c
                - |
                  curl -Lo /assets/kubectl https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl
                  chmod +x /assets/kubectl
              volumeMounts:
                - name: assets
                  mountPath: /assets
          containers:
            - name: app
              image: eu.gcr.io/revolgy-vaimo-edu/training/application:working
              ports:
                - containerPort: 8080
              volumeMounts:
                - name: assets
                  mountPath: /assets
    ```

10. open a new shell

    ```bash
    kubectl exec -it deploy/app -- bash
    ```

11. check if the assets is really there

    ```bash
    ls /assets
    ```

12. now let's also try some simple sidecat. This sidecar simulates some more complicated proxy like service mesh container. 

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app
      labels:
        app: app
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: app
      template:
        metadata:
          labels:
            app: app
        spec:
          volumes:
            - name: assets
              emptyDir: {}
          initContainers:
            - name: download-assets
              image: eu.gcr.io/revolgy-vaimo-edu/training/application:working
              command:
                - sh
                - -c
                - |
                  curl -Lo /assets/kubectl https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl
                  chmod +x /assets/kubectl
              volumeMounts:
                - name: assets
                  mountPath: /assets
          containers:
            - name: app
              image: eu.gcr.io/revolgy-vaimo-edu/training/application:working
              ports:
                - containerPort: 8080
              volumeMounts:
                - name: assets
                  mountPath: /assets
            - name: proxy
              image: alpine/socat
              args:
                - tcp-listen:8081,fork
                - tcp:127.0.0.1:8080
              ports:
                - containerPort: 8081
    ```

13. check if all pods are running and forward your local port `8081` to pod's port `8081`

    ```bash
    kubectl port-forward deploy/app 8081:8081
    ```

    and verify if you receive something

    ```bash
    curl localhost:8081
    ```

    or

    ```powershell
    Invoke-WebRequest http://localhost:8081
    ```

14. leave the Deployment running, we're gonna need it soon

15. and move to the [next section](./02_simple_service.md)
