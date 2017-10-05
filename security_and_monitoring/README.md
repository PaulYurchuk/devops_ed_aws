# Security and Monitoring - Webinar #5
## Webinar practice agenda
* IAM users and roles
* Cloud Watch monitoring

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

### IAM users and roles
* Create role with policy
[s3_role.json](examples/s3_role.json)

* Create instance profile

```
aws iam create-instance-profile --instance-profile-name devops_ed
```

* Add roles to instance profile

```
aws iam add-role-to-instance-profile --instance-profile-name devops_ed --role-name devops_s3_role

```

* Run instance with profile

```
aws ec2 run-instances --image-id ami-08842d60 --key-name devops_ed_aws --instance-type m3.medium --iam-instance-profile Name=devops_s3_role
```

* Check access to s3 from isntance
 
```
ssh -i ../AWS/devops_ed_aws.pem ec2-user@ec2-54-160-104-80.compute-1.amazonaws.com
[ec2-user@ip-10-33-171-241 ~]$ aws s3 ls
2013-01-31 11:34:41 bucket1
2013-01-31 11:35:01 bucket2
...
2012-09-20 09:55:42 bucketN
```

* User data example

```
aws s3 mb s3://devops_ed_scripts --profile epam

aws s3 sync . s3://devops_ed_scripts --profile epam
upload: ./set_env.sh to s3://devops_ed_scripts/set_env.sh
upload: ./mem.sh to s3://devops_ed_scripts/mem.sh
upload: ./instance_init.sh to s3://devops_ed_scripts/instance_init.sh
upload: ./instance_bootstrap.sh to s3://devops_ed_scripts/instance_bootstrap.sh

aws ec2 run-instances --image-id ami-08842d60 --key-name devops_ed_aws --instance-type m3.medium --iam-instance-profile Name=devops_s3_role --user-data file://./scripts/instance_init.sh 


```
### Cloud Watch monitoring
* Add access to role:  
[s3_cwt_role.json](examples/s3_cwt_role.json)
* Create script for pushing metric:  
[mem.sh](scripts/mem.sh)
* Use new script to bootstrap instance  
[instance_init.sh](scripts/instance_init.sh)
