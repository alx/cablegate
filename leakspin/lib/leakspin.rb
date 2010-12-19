$LOAD_PATH << './lib'
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'bundler'

Bundler.require

require 'models.rb'

class LeakSpin < Sinatra::Application
  set :sessions, true
  set :logging, true
  set :raise_errors, true
  set :root, APP_ROOT
  
  helpers do
    def fill_db_content
      Question.create(:content => "Select the subject", 
        :help => "Select text and press enter", 
        :metadata_name => "subject")
    
      Dir.glob(File.join("..", "/cables/*")).each do |cable|
        header = ""
        content = ""
        cable_id = File.basename(cable, ".txt")
        has_header = false

        db_cable = Cable.create(:cable_id => cable_id)
      
        begin
            file = File.new(cable, "r")
            line_number = 1
            while (line = file.gets)
              if has_header
                if line =~ /^\302\266/i
                  db_cable.fragments << Fragment.create(:content => content, :type => :content, :line_number => line_number)
                  content = ""
                else
                  content << line
                end
              elsif line =~ /^\302\266/i
                db_cable.fragments << Fragment.create(:content => header, :type => :header, :line_number => line_number)
                has_header = true
                content = line
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
  end
  
  ######
  # Datamapper methods - clean before prod
  
  get '/clean_db' do
    Datamapper.auto_migrate!
  end
  
  get '/update_db' do
    fill_db_content
  end
  
  ######

  get '/' do
    erb :index
  end
  
  get '/spin.json' do
    content_type :json
    question = Question.first # Fetch a question (only one at the moment)
    fragment = Fragment.get(1 + Fragment.count) # Fetch random fragment
    Hash.new[:question => question, :fragment => fragment].to_json
  end
  
  post '/spin' do
    if metadata = Metadata.create(:name => params[:metadata][:name], :value => params[:metadata][:value])
      Question.get(params[:question_id]).metadatas << metadata
      Fragment.get(params[:fragment_id]).metadatas << metadata
    end
  end
end
