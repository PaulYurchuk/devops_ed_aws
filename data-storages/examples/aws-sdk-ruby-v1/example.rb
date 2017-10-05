require 'aws-sdk'

s3 = AWS::S3.new

bucket = s3.buckets.create('devops_ed_aws_sdk_bucket')

bucket.exists?

s3.buckets.each do |b|
  puts b.name
end

bucket.delete

bucket = s3.buckets['devops-ed-aws-test']
bucket.objects.each do |obj|
  puts obj.key
end
