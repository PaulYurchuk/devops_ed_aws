# Compute resources - Webinar #1
## Webinar agenda
* EC2 instances
  * Compute Instaces
  * EBS/Ephemeral Volumes
  * Amazon Machine Images
  * Security Groups
  * Elastic IPs
  * Route 53
  * User Data/Meta Data
* Elastic Load Balancing
  * External/Internal ELBs
  * Health Checking
  * Settings
* Autoscaling
  * Lounch Configuration
  * Auto Scaling Groups
  * Auto Scaling Policies

## Instructions
### Prepare tools
* Download and install aws-cli:  
  Linux/Cygwin:  
    ```pip install awscli```  
  Windows:  
    http://aws.amazon.com/cli/
* Get credentials (security ID and key)
* ```aws configure```

### EC2 instance
#### First clean instance
* Pick AMI  
http://aws.amazon.com/amazon-linux-ami/  
https://aws.amazon.com/marketplace/  
* Create SSH key

```
$ aws ec2 describe-key-pairs --profile epam

$ key_name=devops_ed_aws; aws ec2 create-key-pair --key-name $key_name --query 'KeyMaterial' --profile epam --output text > $key_name.pem
```
* Run instance

```
$ aws ec2 run-instances --image-id ami-08842d60 --key-name devops_ed_aws --instance-type m3.medium --profile epam --output text

$ aws ec2 describe-instances --instance-ids i-731a6298 --profile epam --output text

$ ssh -i devops_ed_aws.pem ec2-user@ec2-54-227-172-181.compute-1.amazonaws.com
```

#### Additional volumes
* Create EBS volume

```
$ aws ec2 create-volume --size 10 --availability-zone us-east-1c --profile epam --output text
us-east-1c      2014-09-30T16:09:37.978Z        False   10      None    creating        vol-39f96871    standard

$ aws ec2 describe-volumes --volume-ids vol-39f96871 --profile epam --output text
VOLUMES us-east-1c      2014-09-30T16:09:37.978Z        False   10      None    available       vol-39f96871    standard
```

* Attach it to the instance

```
$ aws ec2 attach-volume --instance-id i-731a6298 --volume-id vol-39f96871 --device /dev/sdb --profile epam
{
    "AttachTime": "2014-09-30T16:12:43.203Z",
    "InstanceId": "i-731a6298",
    "VolumeId": "vol-39f96871",
    "State": "attaching",
    "Device": "/dev/sdb"
}

```
* Mount it within OS

```
[root@ip-10-113-187-198 ~]# mkfs.ext4 /dev/xvdb
[root@ip-10-113-187-198 ~]# mount /dev/xvdb /mnt/volume/
[root@ip-10-113-187-198 ~]# umount /mnt/volume/

```
* Make a snapshot of EBS volume

```
$ aws ec2 create-snapshot --volume-id vol-39f96871 --profile epam
None    False   852587906425    None    snap-35821f91   2014-09-30T16:20:47.000Z        pending vol-39f96871    10

```
* Attach it to another instance

```
$ aws ec2 run-instances --image-id ami-08842d60 --key-name devops_ed_aws --instance-type m3.medium --profile epam

$ aws ec2 create-volume --snapshot-id snap-35821f91 --availability-zone us-east-1c --profile epam
us-east-1c      2014-09-30T16:23:20.328Z        False   10      snap-35821f91   creating        vol-1fe07157    standard

$ aws ec2 attach-volume --instance-id i-fe097115 --volume-id vol-1fe07157 --device /dev/sdb --profile epam
2014-09-30T16:24:58.666Z        /dev/sdb        i-fe097115      attaching       vol-1fe07157

$ aws ec2 describe-instances --instance-ids i-fe097115 --profile epam

$ ssh -i devops_ed_aws.pem ec2-user@ec2-54-87-239-182.compute-1.amazonaws.com

[root@ip-10-47-145-45 ~]# mkfs.ext4 /dev/xvdb
[root@ip-10-47-145-45 ~]# mkdir /mnt/volume
[root@ip-10-47-145-45 ~]# mount /dev/xvdb /mnt/volume/

```

#### Create your own AMI
* Use your configured instance
* Create AMI

```
$ aws ec2 create-image --instance-id i-06b52ae8 --name devops_ed_ami --profile epam
ami-f46ddc9c

$ aws ec2 describe-images --image-ids ami-f46ddc9c --profile epam
IMAGES  x86_64  xen     ami-f46ddc9c    852587906425/devops_ed_ami      machine devops_ed_ami   852587906425    False      /dev/xvda       ebs     simple  available       hvm
BLOCKDEVICEMAPPINGS     /dev/xvda
EBS     True    False   snap-d23d4176   8       standard

```
* Terminate instance

```
$ aws ec2 terminate-instances --instance-ids i-06b52ae8 --profile epam
```
* Lounch new instance(s) using your AMI

```
$ aws ec2 run-instances --image-id ami-f46ddc9c --key-name devops_ed_aws --instance-type m3.medium --profile epam
```

#### Security group settings
* Create security group

```
$ aws ec2 create-security-group --group-name devops_ed_http_ssh --description 'Http and ssh ports' --profile epam
```
* Open traffic only to needed IPs/CIDRs

```
$ aws ec2 authorize-security-group-ingress --group-name devops_ed_http_ssh --cidr 0.0.0.0/0 --protocol tcp --port 80 --profile epam
$ aws ec2 authorize-security-group-ingress --group-name devops_ed_http_ssh --cidr 0.0.0.0/0 --protocol tcp --port 22 --profile epam
```
* Run instance with security group

```
$ aws ec2 run-instances --image-id ami-f46ddc9c --key-name devops_ed_aws --instance-type m3.medium --security-groups devops_ed_http_ssh --profile epam
```
* Open traffic only to AWS objects (instances, balancers)

```
$ aws ec2 authorize-security-group-ingress --group-name devops_ed_http_ssh --source-security-group-name default --profile epam
```

#### Elastic IP - permanent external IP
* Request Elastic IP
* Assign to EC2 instance
* Detach and assign to another instance

#### Wanna human readable name?
* Get DNS zone
* Add zone to Route 53
* Add record set, e.g. 'A' record pointing to EC2 instace

#### Automate instance configuration via UserData
* Create user data script
* Use meta-data
http://169.254.169.254/latest/meta-data/
* Start instace using common AMI with user data

```
$ aws ec2 run-instances --image-id ami-08842d60 --key-name devops_ed_aws --instance-type m3.medium --security-groups devops_ed_http_ssh --user-data file://./scripts/instance_bootstrap.sh --profile epam
```

### Elastic Load Balancer
* Create ELB

```
$ aws elb create-load-balancer --load-balancer-name devops-ed-elb --availability-zones us-east-1c us-east-1b --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80  --profile epam

```
* Register instances

```
$ aws elb register-instances-with-load-balancer --load-balancer-name devops-ed-elb --instances i-9961fe77 i-de024635 --profile epam
INSTANCES       i-9961fe77
INSTANCES       i-de024635
```

* Configure health checks

```
$ aws elb configure-health-check --load-balancer-name devops-ed-elb --health-check Target=HTTP:80/index.html,Interval=10,Timeout=5,UnhealthyThreshold=2,HealthyThreshold=2 --profile epam
HEALTHCHECK     2       10      HTTP:80/index.html      5       2
```
* Adjust settings

### Auto Scaling Group
* Create Lounch Configuration
  a. Using custom AMI
  b. Using user data script

```
  $ aws autoscaling create-launch-configuration --launch-configuration-name devops_ed_lc --image-id ami-08842d60 --key-name devops_ed_aws --instance-type m3.medium --user-data file://./scripts/instance_bootstrap.sh --profile epam
```

* Create auto scaling groups

```
$ aws autoscaling create-auto-scaling-group --auto-scaling-group-name devops_ed_ag --launch-configuration-name devops_ed_lc --min-size 1 --max-size 3 --load-balancer-names devops-ed-elb --availability-zones us-east-1c us-east-1b --profile epam
```
* Add scale policies
* Test