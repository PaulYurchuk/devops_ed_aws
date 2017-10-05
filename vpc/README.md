# VPC - Webinar #4
## Webinar agenda
* VPC and subnets
* EC2 instances inside VPC
* Routing
* Security
* NAT

## Instructions
### Prepare tools
#### AWS CLI
* Download and install aws-cli:  
  Linux/Cygwin:  
    ```pip install awscli```  
  Windows:  
    http://aws.amazon.com/cli/
* Get credentials (security ID and key)
* ```aws configure```

### Create VPC, subnets and IGW

* Create VPC
```
aws ec2 create-vpc --cidr-block '10.10.0.0/16'
```

* Create subnets
```
aws ec2 create-subnet --vpc-id vpc-a360e3c6 --cidr-block '10.10.1.0/24'
aws ec2 create-subnet --vpc-id vpc-a360e3c6 --cidr-block '10.10.2.0/24'
```

### Run and configure instaces

#### Publicly available instances

* Run instance in subnet
```
aws ec2 run-instances --image-id ami-08842d60 --key-name devops_ed_aws --instance-type m3.medium --user-data file://../compute-resources/scripts/instance_bootstrap.sh --subnet-id subnet-df2ae986 --security-group-ids sg-5d343638
```

* Create internat gateway
```
aws ec2 create-internet-gateway --profile epam
```

* Attach IGW to VPC
```
aws ec2 attach-internet-gateway --internet-gateway-id igw-9a7fa1ff --vpc-id vpc-a360e3c6 --profile epam
```

* Create route table
```
aws ec2 create-route-table --vpc-id vpc-a360e3c6 --profile epam
```

* Add route to IGW
```
 aws ec2 create-route --route-table-id rtb-58b23e3d --gateway-id igw-9a7fa1ff --destination-cidr-block 0.0.0.0/0
```

* Associate with subnet
```
aws ec2 associate-route-table --subnet-id subnet-df2ae986 --route-table-id rtb-58b23e3d
```

##### Manual EIP assosiation

* Assign EIP
```
aws ec2 associate-address --allocation-id eipalloc-a4e1fccb --instance-id i-ec8ca801
```

* Test
```
ssh -i ../../AWS/devops_ed_aws.pem ec2-user@54.208.83.74
```

##### Auto EIP assosiation

* Map EIPs automatically setting
```
aws ec2 modify-subnet-attribute --map-public-ip-on-launch --subnet-id subnet-df2ae986
```

* Run instance
```
aws ec2 run-instances --image-id ami-08842d60 --key-name devops_ed_aws --instance-type m3.medium --user-data file://../compute-resources/scripts/instance_bootstrap.sh --subnet-id subnet-df2ae986 --security-group-ids sg-5d343638
```

* Test
```
aws ec2 describe-instances --instance-ids i-af634442
ssh -i ../../AWS/devops_ed_aws.pem ec2-user@54.86.238.215
curl 54.86.238.215
```

#### Private instances under NAT

* Run instance in subnet
```
aws ec2 run-instances --image-id ami-08842d60 --key-name devops_ed_aws --instance-type m3.medium --user-data file://../compute-resources/scripts/instance_bootstrap.sh --subnet-id subnet-ce2ae997 --security-group-ids sg-5d343638
```

* Test
```
scp -i ../../AWS/devops_ed_aws.pem ../../AWS/devops_ed_aws.pem ec2-user@54.86.238.215:
ssh -i ../../AWS/devops_ed_aws.pem ec2-user@54.86.238.215
ssh -i devops_ed_aws.pem ec2-user@10.10.2.113
ping 8.8.8.8
```

* Launch NAT instance
```
aws ec2 describe-images --filter Name="owner-alias",Values="amazon" --filter Name="name",Values="amzn-ami-vpc-nat*"
aws ec2 run-instances --image-id ami-ad227cc4 --instance-type t1.micro --subnet-id subnet-df2ae986 --security-group-ids sg-5d343638
```

* Disable source/dest check
```
aws ec2 modify-instance-attribute --instance-id i-f8775015 --no-source-dest-check
```

* Add route to NAT
```
aws ec2 create-route --route-table-id rtb-48b73b2d --instance-id i-f8775015 --destination-cidr-block 0.0.0.0/0
```

* Test
```
scp -i ../../AWS/devops_ed_aws.pem ../../AWS/devops_ed_aws.pem ec2-user@54.86.238.215:
ssh -i ../../AWS/devops_ed_aws.pem ec2-user@54.86.238.215
ssh -i devops_ed_aws.pem ec2-user@10.10.2.113
ping 8.8.8.8
```