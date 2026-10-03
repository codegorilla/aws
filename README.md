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

Updating Operating System
-------------------------

Update the operating system.

> Note: The command below applies only those patches required to maintain a
> secure baseline.

```bash
$ sudo dnf update-minimal --security
```

Installing OCP Utilities
------------------------

Install Cloud Credential Operator Control (ccoctl) utility.

```bash
$ aws s3 cp s3://saber-ocp-artifacts/ccoctl-linux.tar.tar .
$ tar -xvf ccoctl-linux.tar.tar
$ sudo cp ccoctl /usr/local/bin
$ sudo ln -s /usr/local/bin/ccoctl /usr/bin/ccoctl
$ rm ccoctl
```

Install OpenShift Client (OC) utility.

```bash
$ aws s3 cp s3://saber-ocp-artifacts/openshift-client-linux-amd64-rhel9.tar.tar .
$ tar -xvf openshift-client-linux-amd64-rhel9.tar.tar
$ sudo cp kubectl /usr/local/bin
$ sudo cp oc /usr/local/bin
$ sudo ln -s /usr/local/bin/kubectl /usr/bin/kubectl
$ sudo ln -s /usr/local/bin/oc /usr/bin/oc
rm kubectl
rm oc
```

Install OpenShift Client (OC) Mirror utility.

```bash
$ aws s3 cp s3://saber-ocp-artifacts/oc-mirror-rhel9-linux-amd64.tar .
$ tar -xvf oc-mirror-rhel9-linux-amd64.tar
$ sudo cp oc-mirror /usr/local/bin
$ sudo ln -s /usr/local/bin/oc-mirror /usr/bin/oc-mirror
$ rm oc-mirror
```

Install OpenShift Install utility.

```bash
$ aws s3 cp s3://saber-ocp-artifacts/openshift-install-linux.tar.tar .
$ tar -xvf openshift-install-linux.tar.tar
$ sudo cp openshift-install /usr/local/bin
$ sudo ln -s /usr/local/bin/openshift-install /usr/bin/openshift-install
$ rm openshift-install
```

Create an image set configuration:

```yaml
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v2alpha1
mirror:
  platform:
    channels:
      - name: stable-4.22
        minVersion: 4.22.15
        maxVersion: 4.22.15
    graph: true
  operators:
    - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.22
      packages:
        - name: aws-load-balancer-operator
          channels:
            - name: stable-v1
```

Mirror the images to disk.

```
$ oc mirror -c platform-imagesetconfig.yml file://mirror-images --v2
```

Configure ECR. It might be possible to configure a repository
creation template so that the images can be pushed without having to
pre-create the repositories. So far no luck.

Pre-create "openshift/release" and "openshift/release-images" repositories.

Get login credentials for ECR.

> Note: The following command appends the credentials to the
> $XDG_RUNTIME_DIR/containers/auth.json file. It creates the file if
> it does not already exist.

> Note: These credentials expire after 12 hours.

```bash
$ aws ecr get-login-password --region us-east-2 | podman login --username AWS --password-stdin 164599051561.dkr.ecr.us-east-2.amazonaws.com
```

Push the mirror images to the mirror registry.

```bash
$ oc mirror -c platform-imagesetconfig.yml --from file://mirror-images docker://164599051561.dkr.ecr.us-east-2.amazonaws.com --v2
```


AWSTemplateFormatVersion: '2010-09-09'
Description: ECR Repository Creation Template under openshift prefix

Resources:
  RepositoryCreationTemplate:
    Type: 'AWS::ECR::RepositoryCreationTemplate'
    Properties:
      Prefix: openshift
      AppliedFor:
        - CREATE_ON_PUSH
      ImageTagMutability: MUTABLE
      EncryptionConfiguration:
        EncryptionType: AES256
