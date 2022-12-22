## Health probes

1. make sure you're in the correct namespace [link](../pt2/00_single_pod.md)

2. customize the deployment a bit and add a readiness probe to the container

    ```yaml
              readinessProbe:
                periodSeconds: 10
                httpGet:
                  port: http
                  path: /_health/ready
    ```

    > please note newly intoroduced `readinessProbe` stanza.

3. wait for the finished RollingUpdate and send following request to your ingress

    ```bash
    curl https://<your namespace>.workshop.stepanvrany.cz/_health/set/notready -v
    ```

4. watch what's happening in your namespace


    <details>
    <summary>Click to expand!</summary>

    ```bash
    watch kubectl get pod
    ```
    </details>

5. try do describe one of your pod


    <details>
    <summary>Click to expand!</summary>

    ```bash
    kubectl describe pod <name of the pod>
    ```
    </details>

6. now, list `endpoints` in your namespace


    <details>
    <summary>Click to expand!</summary>

    ```bash
    kubectl get endpoints
    ```
    </details>

7. open a new shell in not-ready pod and make it work again

    ```bash
    curl http://localhost:8080/_health/set/ready
    ```

8. watch what's happening in your namespace

    <details>
    <summary>Click to expand!</summary>

    ```bash
    watch kubectl get pod
    ```
    </details>

9. list `endpoints` in your namespace

    <details>
    <summary>Click to expand!</summary>

    ```bash
    kubectl get endpoints
    ```
    </details>

10. let's apply the next change:

    1. set image tag to `working`
    2. add following liveness probe to the container

    ```yaml
              livenessProbe:
                initialDelaySeconds: 60
                periodSeconds: 10
                httpGet:
                  port: http
                  path: /_health/alive
    ```

    > please note newly intoroduced `livenessProbe` stanza.

11. and simulate failure with following http request:

    ```bash
    curl https://<your namespace>.workshop.stepanvrany.cz/_health/set/notalive -v
    ```

12. watch what's happening in your namespace

    <details>
    <summary>Click to expand!</summary>

    ```bash
    watch kubectl get pod
    ```
    </details>
