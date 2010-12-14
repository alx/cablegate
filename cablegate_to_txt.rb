require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'hpricot'
require 'open-uri'
require 'date'

####
# Wikileak CableGate Parser
#
# First release CableGate release (220 cables) has an index with info about all cables.
# Extract these info and fetch the content of each file to rebuild a text only version of the content
# 

options = {}

###
###

options[:ip_root] = "213.251.145.96"
#options[:ip_root] = "www.wikileaks.ch"

###
###

## Optional
options[:web_root] = "http://#{options[:ip_root]}"
#web_root = "http://localhost/~alx/wikileaks"
options[:scrape_root] = "/home/alex/wikileaks/cablegate"
options[:updated] = false
options[:new_cables] = []
####

def write_cable(cable, options = {})
  
  cable_local = File.join("#{options[:scrape_root]}/cables", "#{cable[:id]}.txt")
  cable_remote = "#{options[:web_root]}/cable/#{cable[:date].strftime("%Y/%m")}/#{cable[:id]}.html"
  
  unless File.exists? cable_local
    
    options[:updated] = true
    options[:new_cables] << cable

    p cable_remote
    cable_document = Hpricot(open(cable_remote))

    cable[:content] = ""
    (cable_document/"//pre").each do |content|
      cable[:content] << content.inner_html.gsub("#x000A;", "\n").gsub(/&$/, "").gsub(/<a.[^>]*>/, "").gsub("</a>", "")
    end

    cable_file_content = ""
    cable_file_content << cable[:id]
    cable_file_content << "\n"
    cable_file_content << cable[:title]
    cable_file_content << "\n"
    cable_file_content << cable[:date].to_s
    cable_file_content << "\n"
    cable_file_content << cable[:classification]
    cable_file_content << "\n"
    cable_file_content << cable[:origin]
    cable_file_content << "\n"
    cable_file_content << cable[:content]
    
    cable_file = File.join("#{options[:scrape_root]}/cables", "#{cable[:id]}.txt")
    p "cable_file: #{cable_file}"
    File.open(cable_file, "w") do |f|
      f.write cable_file_content
    end
  end
end

def dispatch_cables_into_folders(options = {})

  if(options[:new_cables].size > 0)
    options[:new_cables].each do |cable|
      cable_file = File.join("#{options[:scrape_root]}/cables", "#{cable[:id]}.txt")
      [
      "#{options[:scrape_root]}/dates/#{cable[:date].strftime("%Y/%m")}",
      "#{options[:scrape_root]}/classification/#{cable[:classification]}",
      "#{options[:scrape_root]}/origin/#{cable[:origin]}",
      "#{options[:scrape_root]}/rel_date/#{options[:rel_date]}/"
      ].each do |folder|
        FileUtils.mkdir_p folder
        FileUtils.cp cable_file, File.join(folder, "#{cable[:id]}.txt")
      end
    end
  end
end

def parse_index(document, options = {})
  
  (document/"//tr").each do |c|
  
    cable = {}
    current_index = 0
    
    if cable_info = (c/"//td")
      if cable_info[0]
        6.times do |index|
          case index
          when 0
            cable[:id] = (cable_info[index]/"/a").inner_html
          when 1
            cable[:title] = cable_info[index].inner_html
          when 2
            cable[:date] = Time.parse((cable_info[index]/"/a").inner_html)
          when 3
            cable[:release_date] = Time.parse((cable_info[index]/"/a").inner_html)
          when 4
            cable[:classification] = (cable_info[index]/"/a").inner_html
          when 5
            cable[:origin] = (cable_info[index]/"/a").inner_html
          end
        end
        write_cable(cable, options)
      end
    end
  end
end

def parse_date(date, options = {})
  page = 0
  wikileaks_request = Net::HTTP.new(options[:ip_root], 80)
  while (wikileaks_request.request_head("/reldate/#{date.strftime("%Y-%m-%d")}_#{page}.html").kind_of? Net::HTTPOK)
    p "#{options[:web_root]}/reldate/#{date.strftime("%Y-%m-%d")}_#{page}.html"
    document = Hpricot(open("#{options[:web_root]}/reldate/#{date.strftime("%Y-%m-%d")}_#{page}.html"))
    options[:rel_date] = date.strftime("%Y/%m/%d")
    parse_index(document, options)
    page += 1
  end
end
  
publication_date = DateTime.parse("11/28/2010")

while publication_date.strftime("%Y%m%d") != (Date.today + 1).strftime("%Y%m%d")
  p publication_date.strftime("%Y%m%d")
  parse_date(publication_date, options)
  publication_date += 1
end

if options[:updated]
  dispatch_cables_into_folders(options = {})
end