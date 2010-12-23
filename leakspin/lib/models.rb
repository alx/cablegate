class Cable
  include DataMapper::Resource

  property :cable_id, String, :required => true, :key => true

  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :fragments
  has n, :metadatas, :through => :fragments
end

class Fragment
  include DataMapper::Resource

  property :id,  Serial
  property :content, Text
  property :type, Enum[:content, :header], :default => :content
  property :line_number, Integer

  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :cable
  has n, :metadatas
end

class Metadata
  include DataMapper::Resource

  property :id,  Serial
  property :name, Text
  property :value, Text
  property :validated, Boolean, :default => false

  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :fragment
  belongs_to :question
end

class Question
  include DataMapper::Resource

  property :id,  Serial
  property :content, Text
  property :help, Text
  property :metadata_name, Text
  property :type, Enum[:unique, :list], :default => :unique

  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :metadatas
end

if File.exists? "/Users/alx/"
  DataMapper.setup(:default, 'sqlite:///Users/alx/leakspin.db')
else
  DataMapper.setup(:default, 'postgres://localhost/leakspin')
end

DataMapper.finalize
DataMapper.auto_upgrade!