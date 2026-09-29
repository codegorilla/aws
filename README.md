# aws

AWS stuff


EKS Cluster Manager
===================

Launch EKS cluster manager EC2 instance. Enable a public IP address.

Installing kubectl
------------------

1. Determine the latest stable release version:

```bash
$ curl https://dl.k8s.io/release/stable.txt
```

2. Download the binary:

```bash
$ sudo curl -O https://dl.k8s.io/release/v1.37.1/bin/linux/amd64/kubectl
```

3. Grant executable permissions to the binary:

```bash
$ sudo chmod +x kubectl
```

4. Move the binary into your PATH

```bash
$ sudo mv kubectl /usr/local/bin/kubectl
```

5. Verify the installation

```bash
$ kubectl version --client
```

Run the following command to configure the kubeconfig file:

```bash
$ aws eks update-kubeconfig --region us-east-2 --name Dev
```


EKS Cluster
===========

Not sure if this is required on subnets. I added it manually to try
to fix a problem, but the problem was actually caused by something else.

```
kubernetes.io/cluster/Dev = shared
```

Pod manifest:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: httpd-pod
  labels:
    app: httpd
spec:
  containers:
    - name: httpd-container
      image: httpd:latest
      ports:
        - containerPort: 80
```

Service manifest:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
  name: httpd-service
spec:
  type: LoadBalancer
  selector:
    app: httpd
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```
