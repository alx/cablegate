require 'rubygems'
require 'dm-core'
require 'dm-types'
require 'dm-migrations'

DataMapper.setup(:default, 'sqlite://leakspin.db')

class Cable
  include DataMapper::Resource
  
  property :id,  Serial
  property :cable_id, String, :required => true
  
  has n, :fragments
  has n, :metadatas, :through => :fragments
end

class Fragment
  include DataMapper::Resource
  
  property :id,  Serial
  property :content, Text
  property :type, Enum[:content, :header], :default => :content
  
  belongs_to :cable
  has n, :metadatas
end

class Metadata
  include DataMapper::Resource
  
  property :id,  Serial
  property :name, Text
  property :value, Text
  property :valid, Boolean, :default => false
  
  belongs_to :fragment
end

DataMapper.finalize
DataMapper.auto_migrate!

Dir.glob(File.join("..", "/cables/*")).each do |cable|
  header = ""
  content = ""
  cable_id = File.basename(cable, ".txt")
  has_been_classified = false
  
  db_cable = Cable.create(:cable_id => cable_id)
  
  begin
      file = File.new(cable, "r")
      while (line = file.gets)
        if has_been_classified
          if line == "\n"
            db_cable.fragments << Fragment.create(:content => content, :type => :content)
            content = ""
          else
            content << line
          end
        elsif line =~ /^classified by/i
          db_cable.fragments << Fragment.create(:content => header, :type => :header)
          has_been_classified = true
        else
          header << line
        end
      end
      file.close
  rescue => err
      puts "Exception: #{err}"
  end
end