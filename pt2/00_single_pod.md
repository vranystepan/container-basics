## Single pod creation

First of all, we'll get through some kubectl basics. We'll try to check namespaced
and cluster-scope resources, we'll try some basic verbs you're gonna need.

---

Let's go through the basic scenario with the smallest schedulable unit - pod. This is something you most likely won't do do in real life
since standalone pods are extremly uncomfortable to use. You will se
soon.

---

1. obtain kubeconfig from AWS API

    ```bash
    gcloud container clusters get-credentials workshops-01 --zone europe-central2-a --project revolgy-vaimo-edu
    ```

    and create your namespace

    ```bash
    kubectl create namespace <name and surname delimited by dash>
    ```

2. make sure you're in the correct namespace

    ```bash
    kubectl config set-context --current --namespace=<assigned namespace>
    ```

3. create a local file (e.g. `pod.yaml`) with the following contents:

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: app
    spec:
      containers:
        - name: app
          image: eu.gcr.io/revolgy-vaimo-edu/training/application:working
          ports:
            - containerPort: 8080
    ```

    and apply this file to the Kubernetes with `kubectl apply` command e.g.

    ```bash
    kubectl apply -f pod.yaml
    ``` 

4. check if the pod is running

    ```bash
    kubectl get pods
    ```

5. describe the pod

    ```bash
    kubectl describe pod app
    ```

    > try to experiment with `get` and `describe` commands a bit,
    > you can use these commands to interact with any object and
    > get some interesting information. Some objects are regularly
    > updated by their controllers so you can even fetch some
    > very relevant lifecycle information. For instance, try to
    > get `node` resource and then describe one of them.

6. open a new shell in this pod

    ```bash
    kubectl exec -it app -- bash
    ```

7. now try to edit some parameters of this pod

    ```bash
    kubectl edit pod app
    ```

    > Once again, you can edit any resource you want. But you should not do it
    > in the production environment. Try to rather keep the truth in the
    > git repository. Always.

8. yeah, it does not work!

9. so just delete it, we don't need it anymore.

    ```bash
    kubectl delete pod app
    ```

10. and move to the [next section](./01_deployment.md), that's gonna be fun!
