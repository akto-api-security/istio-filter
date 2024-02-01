# envoy module for istio

This module is used to send traffic to akto from envoy proxy in an istio setup

The lua-rdkafka module is referenced from here: https://github.com/qiuyifan/luardkafka

### Steps to deploy: 

1. We need some dependencies inside the istio-proxy container to run akto traffic collector. To create the container clone this repo and run the following commands.

```bash
docker build . -t <your-docker-id>:istio-proxy
docker push <your-docker-id>:istio-proxy
```

2. Istio allows us to use custom istio-proxy containers for any pod. We will add the container we created to the pod from which we want to send data to akto. For more information on custom istio-proxy you can check the [official docs](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#customizing-injection). You also need to add the You can add the istio-proxy container as follows:

```yaml
...
    spec:
      serviceAccountName: echo-server
      containers:
      - name: echo-server
        image: coastaldemigod/echo-server:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        # do not change the name of the container, it is used by istio to identify the istio-proxy sidecars.
      - name: istio-proxy
        image: <your-docker-id>/istio-proxy:latest
        env:
        - name: AKTO_KAFKA_IP
          # you will find this on your akto dashboard after you've deployed the traffic processing stack using akto.
          value: "<AKTO_NLB_IP>:9092"
      volumes:
      - name: tmp
        emptyDir: {}
...
```

3. After modifying the configuration, apply it in your kubernetes cluster.
```bash
kubectl apply -f <your-deployment-file>
```

4. Now we will add the envoy filter to the istio-proxy containers. For more information on custom envoy filters you can check the [official docs](https://istio.io/latest/docs/reference/config/networking/envoy-filter). To add that run the following command. You can modify the "match" conditions in the file according to your deployment.

```bash
kubectl apply -f akto-envoy-filter.yaml
```

To delete :
```bash
kubectl delete -f akto-envoy-filter.yaml
```