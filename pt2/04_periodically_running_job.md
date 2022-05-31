## Periodically running job

CronJob is the same idea like Crons in the Unix/Linux/whatever systems.
You put there time expression and stuff is happening periodically.
This resource is widely used in PHP-based services but you can see it
even in other (non-PHP) stacks.

Even I'm using this for some infrastructure tasks like backups
of self-managed services. It just works. But please read the documentation
in order to get some details about the guaranties you have with this
resource.

---

1. make sure you're in the correct namespace [link](./00_single_pod.md)

2. create a local file with the following contents:

    ```yaml
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: cronjob
    spec:
      successfulJobsHistoryLimit: 2
      schedule: "* * * * *"
      jobTemplate:
        spec:
          template:
            spec:
              containers:
              - name: cronjob
                image: nginx
                imagePullPolicy: IfNotPresent
                command:
                  - sh
                  - -c
                  - |
                    curl http://app -H 'User-Agent: cronjob'
              restartPolicy: OnFailure
    ```

    > Please note the `.spec.jobTemplate.spec.template`.  I'm repeating myself here
    > but here we go: it's a pod.

3. wait a few seconds and list spawned jobs

    ```bash
    kubectl get job
    ```

4. also, check the pods spawned by these jobs

    ```bash
    kubectl get pods
    ```

5. and try to manually submit a new job with the cronjob's configuration

    ```bash
    kubectl create job --from=cronjob/cronjob cronjob-manual-01
    ```

    > You can use this to re-run some failed job. Or sometimes you need
    > to run the task sooneer than the cron expressions says.

6. and once again, check the generated resources

    ```bash
    kubectl get jobs
    kubectl get pods
    ```

7. delete the cronjob

    ```bash
    kubectl delete cj cronjob
    ```

8. proceed to the [next section](./05_ingress.md)