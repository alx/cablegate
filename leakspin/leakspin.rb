class LeakSpin < Sinatra::Base
  set :sessions, true
  set :foo, 'bar'
  set :root, File.dirname(__FILE__)

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
    belongs_to :question
  end
  
  class Question
    include DataMapper::Resource

    property :id,  Serial
    property :text, Text
    property :help, Text

    has n, :metadata
  end

  DataMapper.setup(:default, 'sqlite:///Users/alx/leakspin.db')
  DataMapper.finalize
  DataMapper.auto_migrate!
  
  Question.create :text => "Select the subject", :help => "Select text and press enter"

  get '/update_db' do
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
          db_cable.save
          file.close
      rescue => err
          puts "Exception: #{err}"
      end
    end
  end

  get '/' do
    erb :index
  end
  
  get '/spin.json' do
    content_type :json
    cable = Cable.first
    question = Question.first
    { :cable_id => cable.cable_id, :metadata => 'value2' }.to_json
  end
end