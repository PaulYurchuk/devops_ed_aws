require 'aws-sdk'
require 'json'
require 'pp'

dynamo_db = AWS::DynamoDB.new
table = dynamo_db.tables.create(
  'my-table', 10, 5,
  :hash_key => { :id => :string}
)

sleep 1 while table.status == :creating
table.status

filtered_hash = Hash.new
Dir.glob('./cloudtrail/*.json') do |jfile|
  json = File.read(jfile)
  hash = JSON.parse(json)
  
  hash['Records'].each do |k,v|
    filtered_hash["#{k['eventID']}"] = {
      :eventTime => k['eventTime'],
      :eventName => k['eventName'],
      :userName => k['userIdentity']['userName']
    }
  end
end

pp filtered_hash

filtered_hash.each do |k, v|
  puts "==> Inserting #{filtered_hash[k]}"
  item = table.items.put(:id => k)
  item.attributes.set(v)
end

table.items.where(:userName => "Orchestrator").count
table.items.select(:userName, :eventName) { |data| p data.attributes }

table.items.select do |data|
  data.item.delete if data.attributes["eventName"] == "DescribeStacks"
end
