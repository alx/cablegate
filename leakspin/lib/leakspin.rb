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
        :help => "Exemple: 'Subject: abcd' - Select: 'abcd'", 
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
                if line =~ /^\n/i
                  line = file.gets
                  if line =~ /^\n/i
                    db_cable.fragments << Fragment.create(:content => content, :type => :content, :line_number => line_number) unless content.empty?
                    content = ""
                  else
                    content << line
                  end
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
  
  get '/update_db' do
    #fill_db_content
  end
  
  ######

  get '/' do
    erb :index
  end
  
  get '/answers' do
    @questions = Question.all
    erb :answers
  end
  
  get '/spin.json' do
    content_type :json
    
    # Fetch a question (only one at the moment)
    question = Question.first(:metadata_name => 'people')
    
    # Fetch random fragment
    fragment = nil
    while fragment.nil?
      #fragment = Fragment.all(:type => :header, :limit => 1, :offset => rand(Fragment.count)).first
      fragment = Fragment.all(:limit => 1, :offset => rand(Fragment.count)).first
      # do not keep fragment if it has validated metadata
      if fragment
        if fragment.metadatas.count(:validated => true) > 0
          fragment = nil
        elsif fragment.content.strip.empty?
          fragment = nil
        end
      end
    end
    
    {
      :question => {
        :id => question.id, 
        :content => question.content, 
        :help => question.help,
        :metadata_name => question.metadata_name,
        :progress => {
          :total_cables => Cable.all.size,
          :total_answers => question.metadatas.all.size,
        }
      },
      :fragment => {
        :id => fragment.id, 
        :content => fragment.content.gsub("\b", "<br>"),
        :type => fragment.type,
        :cable => {
          :id => fragment.cable.cable_id,
        }
      }
    }.to_json
  end
  
  post '/spin' do
    metadata = Metadata.create(
      :name => params[:metadata][:name], 
      :value => params[:metadata][:value],
      :fragment_id => params[:fragment_id],
      :question_id => params[:question_id])
    "ok"
  end
  
  get 'answers.json' do
    content_type :json
    
    question = Question.get(params[:question_id])
    cable_json = []
    
    cables.all('fragments.metadatas.question_id' => question.id, :limit => 20, :offset => params[:offset]).each do |cable|
      metadatas = []
      cable.fragments.each do |fragment|
        fragment.metadatas.each do |metadata|
          metadatas << {
            :id => metadata.id,
            :validated => metadata.validated
          }
        end
      end
      if metadatas.size > 0
        cable_json << {
          :id => cable.id,
          :content => cable.content,
          :metadatas => metadatas
        }
      end
    end
    
    {
      :question => {
        :id => question.id, 
        :content => question.content, 
        :help => question.help,
        :metadata_name => question.metadata_name,
        :progress => {
          :total_cables => Cable.all.size,
          :total_answers => question.metadatas.all.size,
        }
      },
      :cables => cable_json
    }.to_json
  end
  # 
  # post 'answer' do
  #   metadata = Metadata.get(params[:answer_id])
  #   if params[:status]
  #     case params[:status]
  #     when 'valid'
  #       metadata.update :validated => true
  #     when 'not_valid'
  #       metadata.update :validated => true
  #     when 'delete'
  #       metadata.destroy!
  #     end
  #   end
  # end
end
