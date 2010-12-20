require 'rubygems'
require 'net/http'
require 'nokogiri'
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

if File.exists? "/Users/alx/"
  options[:scrape_root] = "/Users/alx/dev/tetalab/wikileaks/"
else
  options[:scrape_root] = "/home/alex/wikileaks/cablegate"
end

options[:new_cables] = []
####

def parse_index(document, options = {})
  document.xpath("//tr").each do |c|
    cable_details = c.content.strip.split(/\n+/)
    # p "content: #{c.content.strip}"
    unless cable_details[0] == "Reference ID"
      # p "cable_details: #{cable_details.inspect}"
      cable = {}
      cable[:origin] = cable_details.pop
      cable[:classification] = cable_details.pop
      cable[:release_date] = Time.parse(cable_details.pop)
      cable[:date] = Time.parse(cable_details.pop)
      cable[:title] = cable_details.size == 2 ? cable_details.pop : ""
      cable[:id] = cable_details.pop
      write_cable(cable, options)
    end
  end
end

def write_cable(cable, options = {})

  cable_local = File.join("#{options[:scrape_root]}/cables", "#{cable[:id]}.txt")
  cable_remote = "#{options[:web_root]}/cable/#{cable[:date].strftime("%Y/%m")}/#{cable[:id]}.html"

  p cable_remote
  begin
    cable_document = Nokogiri::HTML(open(cable_remote))
    options[:new_cables] << cable

    cable[:content] = ""
    cable_document.xpath("//pre").each do |description|
      cable[:content] << description.content.strip.gsub("&#x000A;", "\n").gsub(/&$/, "").gsub(/<a.[^>]*>/, "").gsub("</a>", "")
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

    p "cable_file: #{cable_local}"
    File.open(cable_local, "w") do |f|
      f.write cable_file_content
    end
  rescue => e
    p "error parsing cable #{e.backtrace}"
  end
end

def git_cable(nb_cables, message = "", options = {})
  g = Git.open(options[:scrape_root])
  g.add(".")
  g.commit_all("Update to #{nb_cables} cables - #{message}")
end

def dispatch_cables_into_folders(options = {})
  if(options[:new_cables].size > 0)
    options[:new_cables].each do |cable|
      cable_file = File.join("#{options[:scrape_root]}/cables", "#{cable[:id]}.txt")
      [
      "#{options[:scrape_root]}/dates/#{cable[:date].strftime("%Y/%m")}",
      "#{options[:scrape_root]}/classification/#{cable[:classification]}",
      "#{options[:scrape_root]}/origin/#{cable[:origin]}",
      "#{options[:scrape_root]}/rel_date/#{cable[:release_date].strftime("%Y/%m/%d")}/"
      ].each do |folder|
        FileUtils.mkdir_p folder
        FileUtils.cp cable_file, File.join(folder, "#{cable[:id]}.txt")
      end
    end
  end
end

def parse_date(date, options = {})
  page = 0
  no_more_page = false
  wikileaks_request = Net::HTTP.new(options[:ip_root], 80)
  begin
    while(!no_more_page)
      path = "#{options[:web_path]}/reldate/#{date.strftime("%Y-%m-%d")}_#{page}.html"
      request = wikileaks_request.request_head(path)
      if (request.kind_of? Net::HTTPOK)
        # p "#{options[:web_root]}/reldate/#{date.strftime("%Y-%m-%d")}_#{page}.html"
        begin
          document_url = "#{options[:web_root]}/reldate/#{date.strftime("%Y-%m-%d")}_#{page}.html"
          document = Nokogiri::HTML(open(document_url))
          options[:rel_date] = date.strftime("%Y/%m/%d")
          parse_index(document, options)
        rescue => e
          p "error parsing document #{document_url}: #{e.backtrace}"
        end
        page += 1
      else
        no_more_page = true
      end
    end
  rescue => e
    p "error getting webpage #{path}: #{e.backtrace}"
  end
end
  
publication_date = DateTime.parse("11/28/2010")
nb_cables_start = Dir[options[:scrape_root] + "/cables/*"].length.to_s

while publication_date.strftime("%Y%m%d") != (Date.today + 1).strftime("%Y%m%d")
  p publication_date.strftime("%Y%m%d")
  parse_date(publication_date, options)
  publication_date += 1
end

nb_cables_end = Dir[options[:scrape_root] + "/cables/*"].length.to_s

if nb_cables_start != nb_cables_end
  p "updated: #{nb_cables_end} cables"
  git_cable(nb_cables_end, "only new cables", options)
  dispatch_cables_into_folders(options)
  git_cable(nb_cables_end, "folder classification", options)
end