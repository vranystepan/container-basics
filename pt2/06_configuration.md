## configuration management

1. make sure you're in the correct namespace [link](./00_single_pod.md)

2. create local files with the following contents:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app
    data:
      CONFIG_SOME_VALUE_1: value1
    ```

    ```yaml
    apiVersion: v1
    data:
      CONFIG_SOME_SECRET_VALUE_1: c2VjcmV0MQ==
    kind: Secret
    metadata:
      name: app
    type: Opaque
    ```

    > please note the value of `CONFIG_SOME_SECRET_VALUE_1`, this is base64-encoded
    > string.

3. also, adjust `app` deployment a bit:

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
              env:
                - name: CONFIG_SOME_SECRET_VALUE_1
                  valueFrom:
                    secretKeyRef:
                      name: app
                      key: CONFIG_SOME_SECRET_VALUE_1
                - name: CONFIG_SOME_VALUE_1
                  valueFrom:
                    configMapKeyRef:
                      name: app
                      key: CONFIG_SOME_VALUE_1
    ```

4. wait a few seconds and open a new shell to your application container

    ```bash
    kubectl exec -it deploy/app -- bash
    ```

5. and list the environment variables

    ```bash
    env | grep "CONFIG_"
    ```

6. update the `app` deployment again

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
              envFrom:
                - configMapRef:
                    name: app
                - secretRef:
                    name: app
    ```

7. wait a few seconds and open a new shell to your application container

    ```bash
    kubectl exec -it deploy/app -- bash
    ```

8. and list the environment variables

    ```bash
    env | grep "CONFIG_"
    ```

9. try to add some value to the ConfigMap


    ```bash
    kubectl edit cm app
    ```

10. open the shell again and list the environment variables

    ```bash
    env | grep "CONFIG_"
    ```

    > It's not there, right? We'll discuss this in the Helm section.
    > Stay tuned.

11. update the `app` deployment again

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
            - name: config
              configMap:
                name: app
          containers:
            - name: app
              image: eu.gcr.io/revolgy-vaimo-edu/training/application:working
              ports:
                - containerPort: 8080
              volumeMounts:
                - name: config
                  mountPath: /etc/config
    ```

12. wait a few seconds and open a new shell to your application container

    ```bash
    kubectl exec -it deploy/app -- bash
    ```

13. list files in `/etc/config`

    ```bash
    ls /etc/config
    cat /ect/config/*
    ```

14. introduce some new change to `app` configmap

15. open a new shell in your pod

    ```bash
    kubectl exec -it deploy/app -- bash
    ```

16. and list files in `/etc/config` again

    ```bash
    ls /etc/config
    cat /ect/config/*
    ```
