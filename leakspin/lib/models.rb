class Cable
  include DataMapper::Resource

  property :cable_id, String, :required => true, :key => true

  has n, :fragments
  has n, :metadatas, :through => :fragments
end

class Fragment
  include DataMapper::Resource

  property :id,  Serial
  property :content, Text
  property :type, Enum[:content, :header], :default => :content
  property :line_number, Integer

  belongs_to :cable
  has n, :metadatas
end

class Metadata
  include DataMapper::Resource

  property :id,  Serial
  property :name, Text
  property :value, Text
  property :validated, Boolean, :default => false

  belongs_to :fragment
  belongs_to :question
end

class Question
  include DataMapper::Resource

  property :id,  Serial
  property :text, Text
  property :help, Text
  property :target_name, Text

  has n, :metadata
end

if File.exists? "/Users/alx/"
  DataMapper.setup(:default, 'sqlite:///Users/alx/leakspin.db')
else
  DataMapper.setup(:default, 'postgres://localhost/leakspin')
end

DataMapper.finalize
unless Cable.all.size > 0
  DataMapper.auto_migrate!
  LeakSpin.fill_db_content
end