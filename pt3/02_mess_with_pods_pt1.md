## Intoduce broken version of the app

1. make sure you're in the correct namespace [link](../pt2/00_single_pod.md)

2. create a local file with the following contents:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app
      labels:
        app: app
    spec:
      replicas: 2
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
              image: eu.gcr.io/revolgy-vaimo-edu/training/application:breaking
              ports:
                - containerPort: 8080
                  name: http
    ```

3. check the status of all pods

    <details>
    <summary>Click to expand!</summary>

    ```bash
    kubectl get pods
    kubectl logs <name of the new pod>
    kubectl describe pod <name of the new pod>
    ```
    </details>

    > Please note that at least one pod is still running,
    > this is called RollingUpdate and this is the way
    > how to prevent downtimes in production

4. try to send some requests to your service

    <details>
    <summary>Click to expand!</summary>

    ```bash
    curl https://<your namespace>.s01.training.eks.rocks
    ```
    </details>

    and check how the `endpoints` look

    <details>
    <summary>Click to expand!</summary>

    ```bash
    kubectl get endpoints
    ```
    </details>

5. now we're gonna deploy slowly starting service. This simulates some startup tasks that sometimes happen in applications.  Create a local file with the following contents:

    ```yaml
              image: eu.gcr.io/revolgy-vaimo-edu/training/application:sleeping
    ```


4. try to send some requests to your service

    <details>
    <summary>Click to expand!</summary>

    ```bash
    curl https://<your namespace>.s02.training.eks.rocks
    ```

    or

    ```powershell
    Invoke-WebRequest https://<your namespace>.s02.training.eks.rocks
    ```
    </details>

    ... we just caused a production outage 😱
