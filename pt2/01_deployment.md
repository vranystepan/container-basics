## Pods managed by Deployment object

Deployments are perhaps the most useful built-in workload-specific objects.
In everyday life, this is the synonym for running something in Kubernetes.
It is easy to configure, it works and there are really good examples
how to work with this object.

---

1. make sure you're in the correct namespace [link](./00_single_pod.md)

2. create a local file (e.g. `deployment.yaml`) with the following contents:

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
              image: docker.io/vranystepan/workshop-app:working
              ports:
                - containerPort: 8080
    ```

    > please note the contentents of `.spec.template`, it's almost the same configuration
    > as we did in the previous module. That's because we are technically still configuring
    > pods but this time we put in place some additional abstraction. Please proceed to the
    > next section to see what such abstraction can do for us.

3. check all the pods

    ```bash
    kubectl get pods
    ```

    > Please note the hashes in the pods' names. The first one comes from the `ReplicaSet`
    > that's responsible for the replication, the second one is random pod's identifier.
    > If you wish, you can list available replicasets with `get` command.

4. and now - delete them. All.

    ```bash
    kubectl delete pod --all
    ```

5. list all the pods again

    ```bash
    kubectl get pods
    ```

    > All the replicas are back again. So you can image what happens if you shutdown
    > one node due to some hw failure or so - nothing significant. Customers can still
    > interact with the application!

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

    > we'll try this in the next section even with different resources. However please
    > bear in mind that this is not something you're gonna use in the production. This
    > is purely for debugging or development. When it comes to exposing your application
    > to the internet - we have better options to achieve this.


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
              image: docker.io/vranystepan/workshop-app:working
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
              image: docker.io/vranystepan/workshop-app:working
              ports:
                - containerPort: 8080
              volumeMounts:
                - name: assets
                  mountPath: /assets
    ```

    > Init containers are actually pretty common. Some companies use them to download
    > pre-built PHP assets to the unified runtime environment. Some companies also
    > use them to download demo data in development environments. I guess you can imagine
    > all the possibilities here. In some highly secure environment we can even use them
    > to change the owner of application files on the volume shared between initContainers
    > and the application containers.

10. open a new shell

    ```bash
    kubectl exec -it deploy/app -- bash
    ```

    > Please note that we don't need to use the full pod's name here.
    > Kubernetes is able to derive the target so when we don't need to
    > operate in the certain pod - you can just use such reference.

11. check if the assets is really there

    ```bash
    ls /assets
    ```

12. now let's also try some simple sidecar. This sidecar simulates some more complicated proxy like service mesh container. 

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
              image: docker.io/vranystepan/workshop-app:working
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
              image: docker.io/vranystepan/workshop-app:working
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

    > Here you can imagine pretty common setup from PHP world.
    > The "main" container is FPM and the sidecar is nginx providing
    > the interface between HTTP and FPM. In the world of GCP you can
    > also find such sidecars providing the access to Cloud SQL databases.

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

15. move to the [next section](./02_simple_service.md)
