## Simple Service

Services are important piece to establist inter-service communication.
They help with load balancing and they also take care of service discovery.

---

1. make sure you're in the correct namespace [link](./00_single_pod.md)

2. create a local file with the following contents:

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: app
    spec:
      selector:
        app: app
      ports:
        - protocol: TCP
          port: 80
          targetPort: 8080
    ```

    > Please note the selector, it matches the labels
    > specified in the previous section! This is how
    > Kubernetes know where route traffice to.

3. get ip addresses of the pods

    ```bash
    kubectl get pods -o custom-columns=NAME:metadata.name,IP:status.podIP
    ```

4. and now list the endpoints created by this service

    ```bash
    kubectl get endpoints
    ```

    > Please note that endpoint contains pods' IP addresses
    > listed in the previous step

5. now create a new temporary pod, you can use file with following contents:

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: cli
    spec:
      containers:
        - name: cli
          image: nginx
    ```

6. open a new shell in this pod

    ```bash
    kubectl exec -it cli -- bash
    ```

    > If you need more details about Kubectl exec, please check
    > following article https://itnext.io/how-it-works-kubectl-exec-e31325daa910

7. and try to reach `app` service from there

    ```bash
    curl http://app -H 'User-Agent: direct-call-from-pod'
    ```

8. you can try even different hostname

    ```bash
    curl http://app.<your namespace> -H 'User-Agent: direct-call-from-pod'
    ```

9. or

    ```bash
    curl http://app.<your namespace>.svc -H 'User-Agent: direct-call-from-pod'
    ```

10. or

    ```bash
    curl http://app.<your namespace>.svc.cluster.local -H 'User-Agent: direct-call-from-pod'
    ```

    > this is what we call service discovery. You can use
    > simple DNS names to reach your services no matter
    > what IP addresses they have. This mechanism works
    > even between namespaces (unless restricted with some more
    > advance networking tools)

11. if you want to see what's running there, you can simply forward container's port to your localhost

    ```bash
    kubectl port-forward svc/app 8080:80
    ```

    > please not the log messages, you have requested service
    > but it's forwarding to the pod. 

    and from the different shell:

    ```bash
    curl localhost:8080
    ```

    or

    ```powershell
    Invoke-WebRequest http://localhost:8080
    ```

12. Good job! Proceed to the [next chapter](./03_one_off_job.md)

