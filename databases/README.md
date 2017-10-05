# Databases - Webinar #3
## Webinar agenda
* RDS - Relational Database Service
* ElastiCache - Memcached/Redis as a service
* DynamoDB - NoSQL database service

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

### RDS
#### Create instance
```
aws rds create-db-instance --db-instance-identifier devops-rds-cli --engine mysql --db-security-groups debops-ed-rds --db-name devopsdb --master-username dev --master-user-password devpassword --no-multi-az --db-instance-class db.m3.medium --allocated-storage 5 --profile epam
```

#### Describe instance
```
aws rds describe-db-instances --db-instance-identifier devops-rds-cli --profile epam
```

#### Insert data
```
mysql -hdevops-rds-cli.cwxbzh7wbasw.us-east-1.rds.amazonaws.com -udev -pdevpassword

mysql> CREATE DATABASE devopsed;
mysql> CREATE TABLE users (id int, firstName varchar(255), lastName varchar(255));
mysql> INSERT INTO users (firstName, lastName) VALUES ('Vasya', 'Pupkin');
mysql> SELECT firstName from users;
+-----------+
| firstName |
+-----------+
| Vasya     |
+-----------+
```

#### Modify, monitore instance

### ElastiCache
#### Create cache cluster
Create cluster via WEB interface, choose redis engine.

#### Put/retreive data
```
aws ec2 run-instances --image-id ami-08842d60 --key-name devops_ed_aws --instance-type m3.medium --security-groups devops-ed-redis --profile epam

aws ec2 describe-instances --instance-ids i-fc1a3b12 --profile epam

ssh -i ~/Work/AWS/devops_ed_aws.pem ec2-user@ec2-54-91-86-228.compute-1.amazonaws.com

gem install redis

require 'redis'
redis = Redis.new(:host => 'devopsed.8l1eap.0001.use1.cache.amazonaws.com', :port => 6379)
redis.ping

redis.set('foo','bar')
redis.get('foo')
```
#### Modify, monitore cluster

### DynamoDB
#### Create DynamoDB table
```
dynamo_db = AWS::DynamoDB.new
table = dynamo_db.tables.create(
  'my-table', 10, 5,
  :hash_key => { :id => :string}
)

sleep 1 while table.status == :creating
table.status
```
#### Insert data
see dynamo_example.rb
```
filtered_hash.each do |k, v|
  puts "==> Inserting #{filtered_hash[k]}"
  item = table.items.put(:id => k)
  item.attributes.set(v)
end
```
#### Retreive data
```
table.items.where(:userName => "Orchestrator").count
table.items.select(:userName, :eventName) { |data| p data.attributes }
```
#### Modify data
```
table.items.select do |data|
  data.item.delete if data.attributes["eventName"] == "DescribeStacks"
end
```