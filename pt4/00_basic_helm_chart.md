## Basic Helm chart

## custom Helm charts for your application pt. I

1. make sure you're in the correct namespace [link](./00_single_pod.md)

2. in your wirking directory, create a new directory with arbitrary name e.g. `chart`

    ```bash
    mkdir chart
    cd chart
    ```

3. create a manifest file for our new Helm chart `Chart.yaml`

    ```yaml
    apiVersion: v2
    name: training-app
    description: A Helm chart for training session
    type: application
    version: 0.0.1
    appVersion: "1.16.0"
    ```

4. create a new `templates` directory

    ```bash
    mkdir templates
    ```

5. and create a new file `deployment.yaml` in this directory (`templates/deployment.yaml`)

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
              image: docker.io/vranystepan/workshop-app:working
              ports:
                - containerPort: 8080
    ```

6. perform a quick check of your chart with `helm template` command

    <details>
    <summary>Click to expand!</summary>

    ```bash
    helm template training-app .
    ```
    </details>

7. let's parametrize the image name, change `templates/deployment.yaml` to this

    ```yaml
              image: {{ .Values.image }}
    ```

8. and create a new file `values.yaml` with the respective value

    <details>
    <summary>Click to expand!</summary>

    ```yaml
    image: docker.io/vranystepan/workshop-app:working
    ```
    </details>

9. perhaps we can make the parametrization more granular, change `templates/deployment.yaml` to this

    ```yaml
              image: {{ .Values.image.name }}:{{ .Values.image.tag }}
    ```
  
11. and update `values.yaml` accordingly

    <details>
    <summary>Click to expand!</summary>

    ```yaml
    image:
      name: docker.io/vranystepan/workshop-app
      tag: working
    ```
    </details>

12. check the rendered resources with `helm template` command again

    <details>
    <summary>Click to expand!</summary>

    ```bash
    helm template training-app .
    ```
    </details>

    > please note that we don't need to specify `--values` flag,
    > since this `values.yaml` file is located directly in the chart
    > stucture - it's used automatically. We call it default values.    

13. let's install this helm chart to the Kubernetes

    <details>
    <summary>Click to expand!</summary>

    ```bash
    helm upgrade --install training-app .
    ```
    </details>

14. Let's parametrize names a bit in `templates/deployment.yaml`, try to use it in all properties using this name.

    ```yaml
        app: {{ .Values.name }}
    ```

    and add name to the `values.yaml`.

    <details>
    <summary>Click to expand!</summary>

    ```yaml
    name: training-app
    image:
      name: docker.io/vranystepan/workshop-app
      tag: working 
    ```
    </details>

15. and try to install this chart again

    <details>
    <summary>Click to expand!</summary>

    ```bash
    helm upgrade --install training-app .
    ```
    </details>


