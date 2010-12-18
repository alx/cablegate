$LOAD_PATH << './lib'
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'bundler'

Bundler.require

require 'models.rb'

class LeakSpin < Sinatra::Application
  set :sessions, true
  set :logging, true
  set :root, APP_ROOT
  
  def self.fill_db_content
    Question.create :text => "Select the subject", :help => "Select text and press enter"
    
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
