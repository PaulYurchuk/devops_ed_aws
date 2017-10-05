# Data storages - Webinar #2
## Webinar agenda
* S3
* Glacier
* Cloud Front

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

#### AWS Ruby SDK
* Get  
  http://aws.amazon.com/sdk-for-ruby/  
  or   
  ```gem install aws-sdk```
* Use  
  ```require 'aws-sdk'```

### S3 Usage
#### AWS-CLI
* List bukets/objects  
  ```aws s3 ls```
* Create bucket  
  ```
  $ aws s3 mb s3://devops_aws_bucket
  make_bucket: s3://devops_aws_bucket/
  ```
* Put/retreive objects
  ```
  $ aws s3 cp file1 s3://devops_aws_bucket/ --profile epam
  upload: ./file1 to s3://devops_aws_bucket/file1
  
  $ aws s3 cp s3://devops_aws_bucket/file1 file1 --profile epam
  download: s3://devops_aws_bucket/file1 to ./file1
 
  $ aws s3 sync ./ s3://devops_aws_bucket --profile epam
  upload: ./file2 to s3://devops_aws_bucket/file2
  ```

* Delete objects
  ```
  $ aws s3 rm s3://devops_aws_bucket/file2 --profile epam
  delete: s3://devops_aws_bucket/file2

  $ aws s3 ls s3://devops_aws_bucket/ --profile epam
  2014-10-09 15:55:23          0 file1
  ```

#### AWS Ruby SDK Examples
  ```ruby
  require 'aws-sdk'
  
  AWS.config(
    :access_key_id => 'YOUR_ACCESS_KEY_ID',
    :secret_access_key => 'YOUR_SECRET_ACCESS_KEY')

  s3 = AWS::S3.new

  bucket = s3.buckets.create('devops_ed_aws_sdk_bucket')
  
  bucket.exists?
  
  s3.buckets.each do |b|
    puts b.name
  end
  
  bucket.delete
  
  bucket = s3.buckets['devops_aws_bucket']
  bucket.objects.each do |obj|
    puts obj.key
  end
  ```
  