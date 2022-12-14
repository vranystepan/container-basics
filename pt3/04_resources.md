## Memory and CPU settings

1. make sure you're in the correct namespace [link](../pt2/00_single_pod.md)

2. update your deployment with following configuration, this configuration belongs to the container's specification.

    ```yaml
              resources:
                requests:
                  cpu: 10000m
                  memory: 128Mi
                limits:
                  cpu: 10000m
                  memory: 128Mi
    ```

3. list all pods in your namespace

    <details>
    <summary>Click to expand!</summary>

    ```bash
    kubectl get pods
    ```
    </details>

    this is what happens when you don't have enought resources available.

    Try to describe one of the pods and get more details

    <details>
    <summary>Click to expand!</summary>

    ```bash
    kubectl describe pod <pod name>
    ```
    </details>

4. now, let's do some more realistic scenario, update deployment as follows

    ```yaml
              resources:
                requests:
                  cpu: 100m
                  memory: 128Mi
                limits:
                  cpu: 100m
                  memory: 128Mi
    ```

5. now, try to fill these 100MiB and check the usage

    ```bash
    curl https://<your namespace>.s02.training.eks.rocks/fill
    ```

    or

    ```powershell
    Invoke-WebRequest -Headers https://<your namespace>.s02.training.eks.rocks/fill
    ```

    and then list the resources used by your application

    ```bash
    kubectl top pods
    ```

    > Please note that it will take some time until
    > values in `top pod` are updated.

6. send a few more requests there and see what happened

    ```bash
    curl https://<your namespace>.workshop.stepanvrany.cz/fill
    ```

    or

    ```powershell
    Invoke-WebRequest -Headers https://<your namespace>.workshop.stepanvrany.cz/fill
    ```

    and then

    ```bash
    kubectl get pods
    ```

    or

    ```bash
    kubectl describe pods
    ```


