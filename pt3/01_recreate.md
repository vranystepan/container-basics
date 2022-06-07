## Recreate update strategy

Now we can just practice the situation when you really don't care about the availability
of your application and you just want to replace all pods with the new ones.

1. make sure you're in the correct namespace [link](../pt2/00_single_pod.md)

2. update the deployment and watch what's happening in your namespace

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app
      labels:
        app: app
    spec:
      replicas: 4
      strategy:
        type: Recreate
      selector:
        matchLabels:
          app: app
      template:
        metadata:
          labels:
            app: app
        spec:
          initContainers:
            # this container just introduces some startup delay
            - name: init-test
              image: busybox
              command:
                - sh
                - -c
                - |
                  sleep 20
          containers:
            - name: app
              image: eu.gcr.io/revolgy-vaimo-edu/training/application:working
              ports:
                - containerPort: 8080
                  name: http
    ```