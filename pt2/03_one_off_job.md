## Get stuff done with one-off Jobs

Standalone jobs are not so often seen but still, they do exist.
One good example: database migrations before updating the Deployment.

---

1. make sure you're in the correct namespace [link](./00_single_pod.md)

2. create a local file with the following contents:

    ```yaml
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: job
    spec:
      template:
        spec:
          containers:
            - name: job
              image: nginx
              command:
                - sh
                - -c
                - |
                  curl http://app -H 'User-Agent: job'
          restartPolicy: Never
      backoffLimit: 4
    ```

    > And here we go again, when you look at `spec.template.spec`, what
    > do you see there? Yup, it's just pod + metadata. Same reason,
    > job controller will ultimately create a pod since that's
    > the only way to run containers in Kubernetes.

3. list the pods

    ```bash
    kubectl get pods
    ```

4. and get the logs of the pod spawned by this job

    ```bash
    kubectl logs <pod name>
    ```

5. optionally get logs from the app service and verify if there's a new event

    ```bash
    kubectl logs deploy/app
    ```

6. delete the job

    ```bash
    kubectl delete job job
    ```

7. update you local file with following contents

    ```yaml
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: job
    spec:
      template:
        spec:
          containers:
            - name: job
              image: nginx
              command:
                - sh
                - -c
                - |
                  curl http://this-does-not-exist
          restartPolicy: Never
      backoffLimit: 4
    ```

8. and watch what's happening in your namespace

    ```bash
    watch kubectl get pods
    ```

    > Try to count the failed pods. Why it does not run infinitely?
    > That's because we have `backoffLimit` specified.

9. view the logs

    ```bash
    kubectl logs job/job
    ```

    > please note that we don't need to specify the pod's name,
    > Kubernetes is able to derive it from the job.

10. proceed to the [next section](04_periodically_running_job.md)
