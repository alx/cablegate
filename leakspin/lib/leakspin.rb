APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'bundler'

Bundler.require

class LeakSpin < Sinatra::Application
  set :sessions, true
  set :root, APP_ROOT
  
  def self.fill_db_content
    Dir.glob(File.join("..", "/cables/*")).each do |cable|
      header = ""
      content = ""
      cable_id = File.basename(cable, ".txt")
      has_been_classified = false

      db_cable = Cable.create(:cable_id => cable_id)
      
      begin
          file = File.new(cable, "r")
          line_number = 1
          while (line = file.gets)
            if has_been_classified
              if line == "\n"
                db_cable.fragments << Fragment.create(:content => content, :type => :content, :line_number => line_number)
                content = ""
              else
                content << line
              end
            elsif line =~ /^classified by/i
              db_cable.fragments << Fragment.create(:content => header, :type => :header, :line_number => line_number)
              has_been_classified = true
            else
              header << line
            end
            line_number += 1
          end
          db_cable.save
          file.close
      rescue => err
          puts "Exception: #{err}"
      end
    end
  end

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

  DataMapper.setup(:default, 'postgres://localhost/leakspin')
  
  unless Cable.all.size > 0
    DataMapper.finalize
    DataMapper.auto_migrate!
    LeakSpin.fill_db_content
  end
  
  Question.create :text => "Select the subject", :help => "Select text and press enter"

  get '/update_db' do
    LeakSpin.fill_db_content
  end

  get '/' do
    erb :index
  end
  
  get '/spin.json' do
    content_type :json
    question = Question.first
    cable = Cable.first
    { :cable => {:id => cable.cable_id, :content => cable.fragments.first(:type => :header).content.gsub("\n", "<br>")}, :question => {:text => question.text, :help => question.help} }.to_json
  end
end
