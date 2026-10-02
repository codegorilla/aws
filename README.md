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

Test:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "internal"
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
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



Installing Helm
---------------

```bash
$ curl -O https://get.helm.sh/helm-v4.3.0-linux-amd64.tar.gz
```

```bash
$ tar -xzvf helm-v4.3.0-linux-amd64.tar.gz
```

```bash
$ sudo cp linux-amd64/helm /usr/local/bin
```

AWS Load Balancer Controller

aws iam create-role \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --assume-role-policy-document file://"pod-identity-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
  --role-name AmazonEKSLoadBalancerControllerRole

aws iam create-role \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --assume-role-policy-document file://"pod-identity-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
  --role-name AmazonEKSLoadBalancerControllerRole

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
}


curl -Lo v2_14_1_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.14.1/v2_14_1_full.yaml

Definitely need cert-manager for AWS Load Balancer Controller to work.

Note: aws-load-balancer-controller was in a crash loop.
Problably due to the following settings in the deployment:

args:
  - --cluster-name=<your-cluster-name>
  - --aws-region=<your-region>
  - --aws-vpc-id=<your-vpc-id>



```bash
# Install EC2 Instance Connect packages
HOST="amazon-ec2-instance-connect-us-west-2.s3.us-west-2.amazonaws.com"
PACKAGE1="ec2-instance-connect-2.0.0-5.rhel9.x86_64.rpm"
PACKAGE2="ec2-instance-connect-selinux-2.0.0-5.noarch.rpm"
mkdir /tmp/ec2-instance-connect
curl https://${!HOST}/latest/linux_amd64/${!PACKAGE1} -o /tmp/ec2-instance-connect/ec2-instance-connect.rpm
curl https://${!HOST}/latest/linux_amd64/${!PACKAGE2} -o /tmp/ec2-instance-connect/ec2-instance-connect-selinux.rpm
dnf install -y /tmp/ec2-instance-connect/ec2-instance-connect.rpm
dnf yum install -y /tmp/ec2-instance-connect/ec2-instance-connect-selinux.rpm
# Install AWS CLI
#curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#dnf install -y unzip
#unzip awscliv2.zip
#sudo ./aws/install
```

```yaml
Version: "2012-10-17"
Statement:
  - Sid: ListObjectsInBucket
    Effect: Allow
    Action:
      - s3:ListBucket
    Resource:
      - arn:aws:s3:::your-bucket-name
  - Sid: PullObjectsFromBucket
    Effect: Allow
    Action:
      - s3:GetObject
      - s3:GetObjectVersion
    Resource:
      - arn:aws:s3:::your-bucket-name/*
```

```yaml
Version: "2012-10-17"
Statement:
  - Effect: Allow
    Principal:
      Service: ://amazonaws.com
    Action: sts:AssumeRole
```