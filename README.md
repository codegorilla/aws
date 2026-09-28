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

Configuring Access
------------------

Run the following command to configure the kubeconfig file:

```bash
$ aws eks update-kubeconfig --region us-east-2 --name Dev
```



How to handle security group access:

Option 1: The "Additional Security Groups" Method (Most Common)When you define an EKS cluster, AWS allows you to pass an array of your own pre-created security groups under the resourcesVpcConfig.securityGroupIds parameter.Create an EKS-Access Security Group: Before building the cluster, create a security group specifically for EKS control plane access (e.g., sg-eks-control-plane).Authorize the Management Instance: Add an inbound rule to sg-eks-control-plane allowing port 443 from your Management EC2 instance's security group.Pass it to EKS during creation: When launching the cluster, attach sg-eks-control-plane to the EKS cluster configuration. AWS will attach this group in addition to the one it creates automatically.


Pod manifest:
  
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

