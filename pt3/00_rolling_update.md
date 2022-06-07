## rolling update

Transition between two versions of Deployment can be configured to use rolling update strategy. During this process, new replicaset is gradually scaled up while the old replicaset is scaled down.

This process can be precisely configured to meet your needs in order to keep some availability or overprovisioning conditions.

This update strategy is the default one but we'll try to adjust the behaviour
of this strategy a bit.

1. make sure you're in the correct namespace [link](../pt2/00_single_pod.md)

2. Create a first version of the deployment

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app
      labels:
        app: app
    spec:
      replicas: 4
      selector:
        matchLabels:
          app: app
      template:
        metadata:
          labels:
            app: app
        spec:
          initContainers:
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

    also create a service and ingress so we can watch what's happening there even
    from the outside

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

    and

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: app
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-prod
    spec:
      ingressClassName: nginx
      tls:
      - hosts:
        - <your namespace>.s02.training.eks.rocks
        secretName: training-tls
      rules:
      - host: <your namespace>.s02.training.eks.rocks
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app
                port:
                  number: 80
    ```

3. now try to introduce a change and watch what's happening with managed pods

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app
      labels:
        app: app
    spec:
      replicas: 4
      selector:
        matchLabels:
          app: app
      template:
        metadata:
          labels:
            app: app
        spec:
          initContainers:
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
              env:
                - name: SOME_VARIABLE
                  value: some-value
    ```

4. now introduce additional change a adjust the strategy a bit

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
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 4
          maxUnavailable: 0
      selector:
        matchLabels:
          app: app
      template:
        metadata:
          labels:
            app: app
        spec:
          initContainers:
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
              env:
                - name: SOME_VARIABLE1
                  value: some-value1
    ```

5. introduce additional change and adust rolling update parameters

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
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 2
          maxUnavailable: 2
      selector:
        matchLabels:
          app: app
      template:
        metadata:
          labels:
            app: app
        spec:
          initContainers:
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
              env:
                - name: SOME_VARIABLE2
                  value: some-value2
    ```