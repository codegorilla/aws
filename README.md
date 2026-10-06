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

Mirroring OCP Container Images
------------------------------

Create platform and operators image set configurations:

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
```

```yaml
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v2alpha1
mirror:
  operators:
    - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.22
      packages:
        - name: aws-load-balancer-operator
          channels:
            - name: stable-v1
```

Get login credentials for ECR.

> Note: The following command appends ECR credentials to the
> $XDG_RUNTIME_DIR/containers/auth.json file. It creates the file if
> it does not already exist. These credentials expire after 12 hours.

```bash
$ aws ecr get-login-password --region us-east-2 | podman login \
  --username AWS \
  --password-stdin \
  123456789123.dkr.ecr.us-east-2.amazonaws.com
```

Mirror platform images to disk.

```bash
$ oc mirror --v2 \
  --config platform-imagesetconfig.yml \
  file://platform-images
```

Push platform images to ECR.

```bash
$ oc mirror \
  --v2 \
  --config platform-imagesetconfig.yml \
  --from file://platform-images \
  docker://123456789123.dkr.ecr.us-east-2.amazonaws.com
```

Mirror operators images to disk.

```bash
$ oc mirror --v2 \
  --config operators-imagesetconfig.yml \
  file://operators-images
```

Push operators images to ECR.

```bash
$ oc mirror \
  --v2 \
  --config operators-imagesetconfig.yml \
  --from file://operators-images \
  docker://123456789123.dkr.ecr.us-east-2.amazonaws.com
```

Creating IAM User for Installation
----------------------------------

Create IAM user named "svc.ocp.installer".

> Note: Do not give access to AWS management console.

Assign "AdministratorAccess" policy directly to the user.

Create an access key for the user.

Create AWS config file:

```bash
$ touch ~/.aws/config
$ chmod 0600 ~/.aws/config
```

```ini
[default]
region = us-east-2
output = json
```

Create AWS credentials file:

```bash
$ touch ~/.aws/credentials
$ chmod 0600 ~/.aws/credentials
```

```ini
[default]
aws_access_key_id = ...
aws_secret_access_key = ...
```

Generate SSH key pair.

> Note: For FIPS-enabled environments, use RSA or ECDSA keys instead
> of ed25519.

```bash
$ ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_rsa_rhcos
```

> Note: For private clusters, we need to create ec2,
> elasticloadbalancing, and s3 endpoints. Additionally, since we are
> using ECR, we also need ecr.dkr and ecr.api endpoints.

> Note: I found that because the cluster could not reach global IAM
> endpoint, and there appears to be no VPC endpoint that you can
> create for that, it seems that some kind of internet access is
> required. This could be done with one or more NAT gateways I
> assume, perhaps in an egress network VPC.

> It is also conceivable that forward proxy could be used and a VPC
> endpoint provided that points to that.

> Another fix is to use short-term credentials, where instead of
> trying to communicate with the IAM global endpoint, it will instead
> communicate with the STS regional endpoint, for which a VPC
> endpoint can be created.

Create install-config.yaml file:

> Note: You must create the file by hand. In a disconnected
> environment, the "openshift-install create cluster ..." command
> will fail because it requires a public hosted zone to be defined.

> Note: Do not use NLB for load balancer type, as it may cause
> hairpinning issues. The default classic load balancer avoids that
> issue. For more information, see Red Hat KB article 140321, titled
> "AWS - hairpin connection failed when router is NLB with internal
> scope" at https://access.redhat.com/solutions/7140321.

```yaml
---
apiVersion: v1
baseDomain: prod.saber.net
compute:
  - architecture: amd64
    hyperthreading: Enabled
    name: worker
    platform:
      aws:
        type: m6i.large
    replicas: 2
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
credentialsMode: Manual
fips: false
imageDigestSources:
  - mirrors:
      - 123456789123.dkr.ecr.us-east-2.amazonaws.com/openshift/release
    source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
  - mirrors:
      - 123456789123.dkr.ecr.us-east-2.amazonaws.com/openshift/release-images
    source: quay.io/openshift-release-dev/ocp-release
metadata:
  name: ocp
networking:
  clusterNetwork:
    - cidr: 10.128.0.0/16
      hostPrefix: 24
  machineNetwork:
    - cidr: 10.2.0.0/16
platform:
  aws:
    hostedZone: Z0123456789ABCDEF
    ipFamily: IPv4
    lbType: Classic
    region: us-east-2
    vpc:
      subnets:
        - id: subnet-1
          roles:
            - type: ControlPlaneInternalLB
            - type: IngressControllerLB
        - id: subnet-2
          roles:
            - type: ControlPlaneInternalLB
            - type: IngressControllerLB
        - id: subnet-3
          roles:
            - type: ControlPlaneInternalLB
            - type: IngressControllerLB
        - id: subnet-4
          roles:
            - type: BootstrapNode
            - type: ClusterNode
        - id: subnet-5
          roles:
            - type: BootstrapNode
            - type: ClusterNode
        - id: subnet-6
          roles:
            - type: BootstrapNode
            - type: ClusterNode
publish: Internal
pullSecret: '{"auths":{"your-mirror-registry.io":{"auth":"..."}}}'
sshKey: |
  ssh-rsa AAAAB3NzaC1yc...your-ssh-public-key...
```

Fill in the SSH key field with your public SSH key.

Fill in the pull secret field with new AWS ECR credentials.

```bash
$ aws ecr get-login-password --region us-east-2 | podman login --username AWS --password-stdin 123456789123.dkr.ecr.us-east-2.amazonaws.com
$ cat $XDG_RUNTIME_DIR/containers/auth.json | jq -c > auth.json
```

Fill in the image digest sources.

Create a working directory.

```bash
$ mkdir cluster
```

Copy OpenShift install config file into working directory.

> Warning: Make sure you copy instead of moving the file because it
> will get consumed when processed.

```bash
$ cp install-config.yaml cluster
```

Create OpenShift install manifests.

```bash
$ openshift-install create manifests --dir=cluster
```

Configuring OCP Cluster to use Short-term Credentials
-----------------------------------------------------

Determine the release image for this particular OCP release.

```bash
$ RELEASE_IMAGE=$(openshift-install version | awk '/release image/ {print $3}')
$ echo $RELEASE_IMAGE
quay.io/openshift-release-dev/ocp-release@sha256:fed788ea...
```

Extract the list of credentials request objects for this particular
OCP release.

```bash
$ oc adm release extract \
  --from=$RELEASE_IMAGE \
  --credentials-requests \
  --included \
  --install-config=install-config.yaml \
  --to=creds-requests
```

Process all credentials request objects extracted above.

```bash
$ ccoctl aws create-all \
  --name=saber-prod \
  --region=us-east-2 \
  --credentials-requests-dir=creds-requests \
  --output-dir=output
```

The above command will create an OpenID Connect identity provider and
an associated public S3 bucket. It will also create IAM roles in
accordance with the credentials requests objects obtained previously,
such as the following:

  * openshift-cloud-credential-operator-cloud-credentials
  * openshift-cloud-network-config-controller-cloud-credentials
  * openshift-cluster-csi-drivers-ebs-cloud-credentials
  * openshift-image-registry-installer-cloud-credentials
  * openshift-ingress-operator-cloud-credentials
  * openshift-machine-api-aws-cloud-credentials

> Note: The public S3 bucket does not contain any particularly
> sensitive information. It contians a "keys.json" file, which is
> just a standard JWKS file, having only a public key inside.
> However, a public bucket may violate blanket security policies. In
> this case, there may be a way to use a private bucket, a pair of
> VPC endpoints ("sts-oidc" interface and "s3" gateway endpoints) to
> meet the requirements. To force creation of a private bucket, use
> "--create-private-s3-bucket" with the "ccoctl aws create-all"
> command.

Copy CCOCTL manifests.

```bash
$ cp output/manifests/* cluster/manifests
```

Copy CCOCTL TLS directory.

```bash
$ cp -a output/tls cluster
```

Create the cluster.

```bash
$ openshift-install create cluster --dir=cluster --log-level=info
```

If you are interrupted, use the following command.

```bash
$ openshift-install wait-for install-complete --dir=./cluster --log-level=info
```

If necessary, destroy the cluster.

> Note: Do not do this unless the cluster install fails or hangs and
> you have no other recourse.

```bash
$ openshift-install destroy cluster --dir=./cluster --log-level=info
```

Copy kubeconfig file to ~/.kube directory.

```bash
$ cp cluster/auth/kubeconfig ~/.kube/config
```

Disable all default sources in OperatorHub. This will terminate the
OpenShift marketplace pods, which are crashing because they cannot
reach the upstream OperatorHub on the internet.

> Note: Since we are having to generate manifests, this could
> theoretically be done during OCP install preparations by including
> a manifest for it. It is something to look into in the future, but
> not a big deal.

```bash
$ oc patch operatorhub cluster \
    --type json \
    --patch '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```

Troubleshooting
---------------

Some messages to watch for:

> INFO Waiting up to 15m0s (until 6:01PM UTC) for network infrastructure to become ready...
> INFO Network infrastructure is ready

> INFO Waiting up to 15m0s (until 6:04PM UTC) for machines to provision...
> INFO Control-plane machines are ready

> INFO Waiting up to 20m0s (until 6:10PM UTC) for the Kubernetes API
> INFO API up

> INFO Waiting up to 45m0s (until 6:49PM UTC) for bootstrapping to complete...
> INFO Waiting for the bootstrap etcd member to be removed...
> INFO Bootstrap etcd member has been removed

> INFO Waiting up to 5m0s for bootstrap machine deletion
> INFO Finished destroying bootstrap resources

> INFO Waiting up to 40m0s (until 7:01PM UTC) for the cluster to initialize...

> INFO Waiting up to 30m0s (until 7:52PM UTC) to ensure each cluster operator has finished progressing...
> INFO All cluster operators have completed progressing

> INFO Install complete!

SSH to bootstrap node.

```bash
$ ssh -i ~/.ssh/id_rsa_rhcos core@<bootstrap-ip-address>
```

Check node-image-pull service.

```bash
$ journalctl -b -f -u node-image-pull.service
```

Check release-image service.

```bash
$ journalctl -b -f -u release-image.service
```

Check bootkube service.

```bash
$ journalctl -b -f -u bootkube.service
```

Check podman. You should see a container running called "cluster-bootstrap".

```bash
$ sudo podman ps
```

Check CRI-O container runtime. You should see several control plane
containers running.

```bash
$ sudo crictl ps
```

Check state of kubernetes nodes. You should see three master nodes.
It may take time for them to become ready, but they should end up
with a "Ready" status.

```bash
$ sudo oc get nodes --kubeconfig=/etc/kubernetes/kubeconfig
```

Check state of pods.

```bash
$ sudo oc get pods -A --kubeconfig=/etc/kubernetes/kubeconfig | grep -v Com | grep -v Run
```

Check state of nodes on management host.

```bash
$ oc get nodes
NAME                                        STATUS   ROLES                  AGE   VERSION
ip-10-2-20-250.us-east-2.compute.internal   Ready    control-plane,master   71m   v1.35.6
ip-10-2-21-249.us-east-2.compute.internal   Ready    control-plane,master   70m   v1.35.6
ip-10-2-21-76.us-east-2.compute.internal    Ready    worker                 14m   v1.35.6
ip-10-2-22-137.us-east-2.compute.internal   Ready    worker                 14m   v1.35.6
ip-10-2-22-210.us-east-2.compute.internal   Ready    control-plane,master   71m   v1.35.6
```

Check state of machine config pools on management host.

```bash
$ oc get mcp
NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED   MACHINECOUNT   READYMACHINECOUNT   UPDATEDMACHINECOUNT   DEGRADEDMACHINECOUNT   AGE
master   rendered-master-b97e1de21e909175d3759f87dcfcee88   True      False      False      3              3                   3                     0                      69m
worker   rendered-worker-1ae974bb5c94643c71556de35edc5017   True      False      False      2              2                   2                     0                      69m
```

Check state of cluster operators on management host.

```bash
$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.22.15   True        False         False      2m43s
baremetal                                  4.22.15   True        False         False      68m
cloud-controller-manager                   4.22.15   True        False         False      70m
cloud-credential                           4.22.15   True        False         False      56m
cluster-autoscaler                         4.22.15   True        False         False      68m
config-operator                            4.22.15   True        False         False      69m
console                                    4.22.15   True        False         False      10m
control-plane-machine-set                  4.22.15   True        False         False      68m
csi-snapshot-controller                    4.22.15   True        False         False      68m
dns                                        4.22.15   True        False         False      68m
etcd                                       4.22.15   True        False         False      67m
image-registry                             4.22.15   True        False         False      13m
ingress                                    4.22.15   True        False         False      13m
insights                                   4.22.15   True        False         False      63m
kube-apiserver                             4.22.15   True        False         False      59m
kube-controller-manager                    4.22.15   True        False         False      64m
kube-scheduler                             4.22.15   True        False         False      66m
kube-storage-version-migrator              4.22.15   True        False         False      69m
machine-api                                4.22.15   True        False         False      14m
machine-approver                           4.22.15   True        False         False      69m
machine-config                             4.22.15   True        False         False      69m
marketplace                                4.22.15   True        False         False      69m
monitoring                                 4.22.15   True        False         False      6m12s
network                                    4.22.15   True        False         False      70m
node-tuning                                4.22.15   True        False         False      13m
olm                                        4.22.15   True        False         False      68m
openshift-apiserver                        4.22.15   True        False         False      56m
openshift-controller-manager               4.22.15   True        False         False      58m
openshift-samples                          4.22.15   True        False         False      54m
operator-lifecycle-manager                 4.22.15   True        False         False      68m
operator-lifecycle-manager-catalog         4.22.15   True        False         False      68m
operator-lifecycle-manager-packageserver   4.22.15   True        False         False      55m
service-ca                                 4.22.15   True        False         False      69m
storage                                    4.22.15   True        False         False      67m
```

System reported install complete:

```
INFO Install complete!
INFO To access the cluster as the system:admin user when using 'oc', run
INFO     export KUBECONFIG=/home/ec2-user/ocp/cluster/auth/kubeconfig
INFO Access the OpenShift web-console here: https://console-openshift-console.apps.ocp.prod.saber.net
INFO Login to the console with user: "***", and password: "***"
INFO Time elapsed: 12m2s
```

- I need to create endpoints with CFn.

- I need a security group for endpoints. Needs to allow tcp/443
inbound any OCP node subnets.

- I need to create NAT GW with CFn. Also need routes to NAT GW from
  EC2 instances and from NAT GW to IGW. NAT GW needs to be in a
  public subnet.


Notes
-----

Ran out of vCPU quota and had to request an increase from 16 to 20.

```bash
$ oc get machines -n openshift-machine-api
```

Two machines were failed because there was not enough vCPU in our
quota. Increased quota from 16 to 20. Deleted failed machines, which
triggered new ones appearing.


Amazon Root CA 1 is not really a root CA?

-----BEGIN CERTIFICATE-----
MIIEkjCCA3qgAwIBAgITBn+USionzfP6wq4rAfkI7rnExjANBgkqhkiG9w0BAQsF
ADCBmDELMAkGA1UEBhMCVVMxEDAOBgNVBAgTB0FyaXpvbmExEzARBgNVBAcTClNj
b3R0c2RhbGUxJTAjBgNVBAoTHFN0YXJmaWVsZCBUZWNobm9sb2dpZXMsIEluYy4x
OzA5BgNVBAMTMlN0YXJmaWVsZCBTZXJ2aWNlcyBSb290IENlcnRpZmljYXRlIEF1
dGhvcml0eSAtIEcyMB4XDTE1MDUyNTEyMDAwMFoXDTM3MTIzMTAxMDAwMFowOTEL
MAkGA1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJv
b3QgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJ4gHHKeNXj
ca9HgFB0fW7Y14h29Jlo91ghYPl0hAEvrAIthtOgQ3pOsqTQNroBvo3bSMgHFzZM
9O6II8c+6zf1tRn4SWiw3te5djgdYZ6k/oI2peVKVuRF4fn9tBb6dNqcmzU5L/qw
IFAGbHrQgLKm+a/sRxmPUDgH3KKHOVj4utWp+UhnMJbulHheb4mjUcAwhmahRWa6
VOujw5H5SNz/0egwLX0tdHA114gk957EWW67c4cX8jJGKLhD+rcdqsq08p8kDi1L
93FcXmn/6pUCyziKrlA4b9v7LWIbxcceVOF34GfID5yHI9Y/QCB/IIDEgEw+OyQm
jgSubJrIqg0CAwEAAaOCATEwggEtMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/
BAQDAgGGMB0GA1UdDgQWBBSEGMyFNOy8DJSULghZnMeyEE4KCDAfBgNVHSMEGDAW
gBScXwDfqgHXMCs4iKK4bUqc8hGRgzB4BggrBgEFBQcBAQRsMGowLgYIKwYBBQUH
MAGGImh0dHA6Ly9vY3NwLnJvb3RnMi5hbWF6b250cnVzdC5jb20wOAYIKwYBBQUH
MAKGLGh0dHA6Ly9jcnQucm9vdGcyLmFtYXpvbnRydXN0LmNvbS9yb290ZzIuY2Vy
MD0GA1UdHwQ2MDQwMqAwoC6GLGh0dHA6Ly9jcmwucm9vdGcyLmFtYXpvbnRydXN0
LmNvbS9yb290ZzIuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkqhkiG9w0BAQsF
AAOCAQEAYjdCXLwQtT6LLOkMm2xF4gcAevnFWAu5CIw+7bMlPLVvUOTNNWqnkzSW
MiGpSESrnO09tKpzbeR/FoCJbM8oAxiDR3mjEH4wW6w7sGDgd9QIpuEdfF7Au/ma
eyKdpwAJfqxGF4PcnCZXmTA5YpaP7dreqsXMGz7KQ2hsVxa81Q4gLv7/wmpdLqBK
bRRYh5TmOTFffHPLkIhqhBGWJ6bt2YFGpn6jcgAKUj6DiAdjd4lpFw85hdKrCEVN
0FE6/V1dN2RMfjCyVSRCnTawXZwXgWHxyvkQAiSr6w10kY17RSlQOYiypok1JR4U
akcjMS9cmvqtmg5iUaQqqcT5NJ0hGA==
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
MIIDQTCCAimgAwIBAgITBmyfz5m/jAo54vB4ikPmljZbyjANBgkqhkiG9w0BAQsF
ADA5MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRkwFwYDVQQDExBBbWF6
b24gUm9vdCBDQSAxMB4XDTE1MDUyNjAwMDAwMFoXDTM4MDExNzAwMDAwMFowOTEL
MAkGA1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJv
b3QgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJ4gHHKeNXj
ca9HgFB0fW7Y14h29Jlo91ghYPl0hAEvrAIthtOgQ3pOsqTQNroBvo3bSMgHFzZM
9O6II8c+6zf1tRn4SWiw3te5djgdYZ6k/oI2peVKVuRF4fn9tBb6dNqcmzU5L/qw
IFAGbHrQgLKm+a/sRxmPUDgH3KKHOVj4utWp+UhnMJbulHheb4mjUcAwhmahRWa6
VOujw5H5SNz/0egwLX0tdHA114gk957EWW67c4cX8jJGKLhD+rcdqsq08p8kDi1L
93FcXmn/6pUCyziKrlA4b9v7LWIbxcceVOF34GfID5yHI9Y/QCB/IIDEgEw+OyQm
jgSubJrIqg0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AYYwHQYDVR0OBBYEFIQYzIU07LwMlJQuCFmcx7IQTgoIMA0GCSqGSIb3DQEBCwUA
A4IBAQCY8jdaQZChGsV2USggNiMOruYou6r4lK5IpDB/G/wkjUu0yKGX9rbxenDI
U5PMCCjjmCXPI6T53iHTfIUJrU6adTrCC2qJeHZERxhlbI1Bjjt/msv0tadQ1wUs
N+gDS63pYaACbvXy8MWy7Vu33PqUXHeeE6V/Uq2V8viTO96LXFvKWlJbYK8U90vv
o/ufQJVtMVT8QtPHRh8jrdkPSHCa2XV4cdFyQzR1bldZwgJcJmApzyMZFo6IQ6XU
5MsI+yMRQ+hDKXJioaldXgjUkK642M4UwtBV8ob2xJNDd2ZhwLnoQdeXeGADbkpy
rqXRfboQnoZsG4q5WTP468SQvvG5
-----END CERTIFICATE-----

> FUTURE NOTE:
> Investigate custom service endpoints for FIPS mode.
