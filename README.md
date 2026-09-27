# aws

AWS stuff


EKS Cluster Manager
===================

Launch EKS cluster manager EC2 instance.

Set up EC2 instance connect. This requires an EC2 instance connect
endpoint, but this should be free of charge.

1. Download the latest stable release binary

```bash
$ sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

2. Grant executable permissions to the binary

```bash
$ sudo chmod +x ./kubectl
```

3. Move the binary into your PATH

```bash
$ sudo mv ./kubectl /usr/local/bin/kubectl
```

4. Verify the installation

```bash
$ kubectl version --client
```

Configure access

Make sure to build the cluster with access method set to API
Assign a role to the management instance and then configure EKS access to allow that role
to admin the EKS cluster.

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

