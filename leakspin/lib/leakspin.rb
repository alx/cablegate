$LOAD_PATH << './lib'
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'bundler'

Bundler.require

require 'auth.rb'
require 'models.rb'

class LeakSpin < Sinatra::Application
  
  register SinatraMore::WardenPlugin
  
  set :sessions, true
  set :logging, true
  set :raise_errors, true
  set :root, APP_ROOT
  
  helpers do
    
    def add_missing_question
      # subject
      Question.create(:content => "Select the subject", 
        :help => "Exemple: 'Subject: abcd' - Select: 'abcd'", 
        :metadata_name => "subject") unless Question.first(:metadata_name => "subject")
      
      # tags
      Question.create(:content => "Select the tag", 
        :help => "Exemple: 'Tags: abc, def' - Select: 'abc, def'", 
        :metadata_name => "tags") unless Question.first(:metadata_name => "tags")
      
      # people
      Question.create(:content => "Select the people", 
        :help => "Exemple: 'Emperor Palpatine' - Select: 'Palpatine'", :type => :list,
        :metadata_name => "people") unless Question.first(:metadata_name => "people")
        
      if question = Question.first(:metadata_name => "people")
        question.update(:type => :list) if question.type == :unique
      end
    end
    
    def fill_db_content
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
    add_missing_question
  end
  
  ######
  
  #
  #
  # HOME
  #
  #
  
  get '/' do
    erb :index
  end
  
  #
  #
  # SPIN
  #
  #
  
  get '/spin.json' do
    content_type :json
    
    # Fetch a question (only one at the moment)
    question = Question.first(:metadata_name => 'people')
    return "{}" unless question
    
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
    
    question_json = {
      :id => question.id, 
      :content => question.content, 
      :help => question.help,
      :metadata_name => question.metadata_name,
      :type => question.type,
      :progress => {
        :total_cables => Cable.all.size,
        :total_answers => question.metadatas.all.size,
      }
    }
    
    question_answers = []
    question.metadatas.all(:fragment_id => fragment.id, :validated => true).each do |metadata|
      question_answers << {
        :id => metadata.id,
        :value => metadata.value
      }
    end
    question_json[:answers] = question_answers
    
    {
      :question => question_json,
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
  
  #
  #
  # ANSWERS
  #
  #
  
  get '/answers' do
    @questions = Question.all
    erb :answers
  end
  
  get '/answers.json' do
    content_type :json
    
    question = Question.get(params[:question_id])
    #return "{}" if question.nil?
    
    metadatas = []
    
    question.metadatas.all(:validated => false, :limit => 10, :order => [:created_at.desc]).each do |metadata|
      metadatas << {
        :id => metadata.id,
        :validated => metadata.validated,
        :name => metadata.name,
        :value => metadata.value,
        :fragment_id => metadata.fragment.id,
        :cable_id => metadata.fragment.cable.cable_id
      }
    end
    
    {
      :question => {
        :id => question.id, 
        :content => question.content, 
        :help => question.help,
        :metadata_name => question.metadata_name,
        :progress => {
          :not_validated => question.metadatas.all(:validated => false).size,
        }
      },
      :metadatas => metadatas
    }.to_json
  end
  
  post '/answers' do
    if params[:status] && metadata = Metadata.get(params[:metadata_id])
      case params[:status]
      when 'valid'
        metadata.update :validated => true
        case metadata.question.type
        when :unique
          # destroy other metadata for this question on this metadata fragment
          metadata.question.metadatas.all(:validated => false, :fragment_id => metadata.fragment_id).destroy!
        when :list
          # destroy other metadata with same value for this question on this metadata fragment
          metadata.question.metadatas.all(:id.not => metadata.id, :value => metadata.value, :fragment_id => metadata.fragment_id).destroy!
        end
      when 'delete'
        metadata.destroy! unless metadata.validated
      end
    end
  end
  
  get '/fragments/:id' do
    Fragment.get(params[:id]).content
  end
  
  post '/metadatas' do
    unless metadata = Metadata.get(params[:id])
      metadata.update :value => params[:value]
    end
  end
  
  #
  #
  # People
  #
  #
  
  get '/people' do
    people_metadatas = Metadatas.all(:name => 'people', :validated => true)
    people = People.all
  end
  
  post '/people' do
    if people = People.get(params[:people_id])
      people.metadatas << Metadata.all(:value => params[:metadatas], :validated => true) if params[:metadatas]
      people.name = params[:name] if params[:name]
      if params[:image_url]
        File.mkdir('../images/people') unless File.exists? '../images/people'
        
        image = open(params[:image_url])
        image_ext = File.extension(params[:image_url])
        people.image_url = "/images/people/#{people.name.gsub(/\s+/, "")}.#{image_ext}"
        
        File.open(File.join('..', people.image_url), "w") do |f|
          f.write image
        end
      end
      people.save
    end
  end
end
