require 'date'

#
# Globals
#

$basedir = '.'

$dated_cables = {}
$tags = []

#
# Helper methods
#

def cable_list_item(basename)
  cables_url = 'http://www.wikileaks.ch/cable'
  cable_data = $dated_cables[basename]
  output = "\n<li><h3><a href='/mobile/cables/#{basename}.html'>#{cable_data[:title]}</a></h3>"
  output << "<p>"
  output << "Tags: #{cable_data[:tags]} - " unless cable_data[:tags].empty?
  output << "#{basename}</p></li>"
  output
end

def list_cables(title, files)
  
  output = ""
  
  output << "\n<li>#{title} <span class='ui-li-count'>#{files.count}</span><ul>" unless title.empty?
  
  files.each{|file| output << cable_list_item(File.basename(file, ".txt"))}
  
  output << "\n</ul></li>" unless title.empty?
  
  output
end

def write_html(filename, content)
  File.open(File.join("mobile", filename), "w") do |f|
    f.write "<!DOCTYPE html> 
    <html> 
    <head> 
    	<meta charset='utf-8' /> 
    	<title>Wikileaks Cablegate - Mobile Version</title> 
    	<link rel='stylesheet' href='http://code.jquery.com/mobile/1.0a2/jquery.mobile-1.0a2.min.css' /> 
    	<script src='http://code.jquery.com/jquery-1.4.4.min.js'></script>
    	<script type='text/javascript' src='http://code.jquery.com/mobile/1.0a2/jquery.mobile-1.0a2.min.js'></script> 
    </head> 
    <body> 
      #{content}
    </body> 
    </html>"
  end
end

def write_index(cable_count, latest_update)
  index_content = "
  <div data-role='page'> 
  	<div data-role='header'> 
  		<h1>Wikileaks CableGate</h1> 
  	</div><!-- /header --> 

  	<div data-role='content'>
  	  <div style='text-align:center'><img src='./images/wikileaks.png' alt='wikileaks'/></div>
  	
  	  <ul data-role='listview' data-inset='true'> 
        <li><a href='#{latest_update[:link]}'>Latest Updates</a> <span class='ui-li-count'>#{latest_update[:count]}</span></li>
        <li><a href='./cables/page_0.html'>All cables</a> <span class='ui-li-count'>#{cable_count}</span></li>
        <li><a href='./classification.html'>By Classification</a></li>
        <li><a href='./origin.html'>By Origin</a></li>
        <li><a href='./release.html'>By Release</a></li>
      </ul>
  	</div><!-- /content --> 
  	
    <div data-role='footer'>
      <div data-role='controlgroup' data-type='horizontal' style='text-align:center'>
  		  <a href='http://jquerymobile.com'>Jquery Mobile</a>
    	  <a href='http://www.wikileaks.ch/support.html'>Support Wikileaks</a>
  		  <a href='http://git.tetalab.org/index.php/p/cablegate/source/tree/master/'>Code</a>
  		</div>
    </div><!-- /foter -->
  </div><!-- /page -->"
  write_html("index.html", index_content)
end

def write_list(filename, list, title = nil, data_filter = false)
  content = "
  <div data-role='page'> 
  	<div data-role='header'> 
  		<h1>#{title || "Wikileaks CableGate"}</h1> 
  	</div><!-- /header --> 

  	<div data-role='content'> 
  		<ul data-role='listview' #{"data-filter='true'" if data_filter}> 
        #{list}
      </ul>
  	</div><!-- /content --> 
  	<div data-role='footer'>
    		<div data-role='controlgroup' data-type='horizontal' style='text-align:center'>
  		    <a href='http://jquerymobile.com'>Jquery Mobile</a>
    		  <a href='http://www.wikileaks.ch/support.html'>Support Wikileaks</a>
    		  <a href='http://git.tetalab.org/index.php/p/cablegate/source/tree/master/'>Code</a>
    		</div>
    </div><!-- /foter -->
  </div><!-- /page -->"
  write_html(filename, content)
end

def write_page(filename, list, title = nil, previous_page = nil, next_page = nil)
  content = "
  <div data-role='page'> 
  	<div data-role='header'>
  	  #{previous_page ? "<a href='#{previous_page}' data-role='button' data-icon='arrow-l'>Previous</a>" : "<a href='http://wikileaks.tetalab.org/mobile/' data-role='button' data-icon='arrow-u'>Home</a>"}
  		<h1>#{title || "Wikileaks CableGate"}</h1>
  		#{"<a href='#{next_page}' data-role='button' data-icon='arrow-r'>Next</a>" if next_page}
  	</div><!-- /header --> 

  	<div data-role='content'>
  		<ul data-role='listview'> 
        #{list}
      </ul>
  	</div><!-- /content --> 
  	<div data-role='footer'>
  	  <div data-role='controlgroup' data-type='horizontal' style='text-align:center'>
    	  #{"<a href='#{previous_page}' data-role='button' data-icon='arrow-l'>Previous</a>" if previous_page}
    	  <a href='/' data-role='button' data-icon='arrow-u'>Home</a>
    	  #{"<a href='#{next_page}' data-role='button' data-icon='arrow-r'>Next</a>" if next_page}
    	</div>
    </div><!-- /foter -->
  </div><!-- /page -->"
  write_html(filename, content)
end

def write_cable(cable_id, content)
  cable_data = $dated_cables[cable_id]
  cables_url = 'http://www.wikileaks.ch/cable'
  content = "
  <div data-role='page'> 
  	<div data-role='header'>
  		<h1>#{cable_data[:title]}</h1>
  		<a href='#{cables_url}/#{cable_data[:date]}/#{cable_id}.html' data-role='button' data-icon='arrow-r'  class='ui-btn-right''>On Wikileaks</a>
  	</div><!-- /header --> 

  	<div data-role='content'>
        #{content}
  	</div><!-- /content -->
  </div><!-- /page -->"
  write_html("cables/#{cable_id}.html", content)
end

def write_section_all
  cable_list = ""
  nb_cables = 0
  cable_pages = []
  Dir.glob(File.join($basedir, "/dates/*")).each do |year_folder|
    year = File.basename(year_folder)
    Dir.glob(File.join(year_folder, "*")).each do |month_folder|
      month = File.basename(month_folder)
      cable_list << "<li data-role='list-divider'>#{DateTime.parse("#{year}-#{month}-01").strftime("%b %Y")} <span class='ui-li-count'>#{Dir.glob(File.join(month_folder, "*")).count}</span></li>"
      
      cable_files = Dir.glob(File.join(month_folder, "*"))
      cable_files.each do |cable|
        cable_list << cable_list_item(File.basename(cable, ".txt"))
      end
      
      nb_cables += cable_files.size
      if nb_cables > 100
        cable_pages << [cable_list]
        cable_list = ""
        nb_cables = 0
      end
    end
  end
  
  previous_page = nil
  cable_pages.each_with_index do |page_cables, index|
    next_page = index == (cable_pages.size - 1) ? nil : "page_#{index + 1}.html"
    write_page("cables/page_#{index}.html", page_cables, "All Cables (#{index + 1}/#{cable_pages.size})", previous_page, next_page)
    previous_page = "page_#{index}.html"
  end
end

def write_section_origin
  origin_list = ""
  files = Dir.glob(File.join($basedir, "/origin/*"))
  files.each do |origin|
    basename = File.basename(origin)
    origin_url = "origin/#{File.basename(origin).downcase.gsub(" ", "_")}.html"
    origin_list << "<li><a href='#{origin_url}'>#{basename} <span class='ui-li-count'>#{files.count}</span></li>"

    cable_list = ""
    Dir.glob(File.join(origin, "/*.txt")).each{|cable| cable_list << cable_list_item(File.basename(cable, ".txt"))}
    write_list(origin_url, cable_list, basename, true)
  end
  write_list("origin.html", origin_list, nil, true)
end

def write_classification(title, folder, html)
  files = Dir.glob(File.join($basedir, "/classification/#{folder}/*.txt"))
  files.each do |classification|
    basename = File.basename(classification)
    cable_list = ""
    files.each{|cable| cable_list << cable_list_item(File.basename(cable, ".txt"))}
    Dir.glob(File.join(classification, "/*.txt")).each{|cable| cable_list << cable_list_item(File.basename(cable, ".txt"))}
    write_list("classification/#{html}.html", cable_list, title, true)
  end
  "<li><a href='classification/#{html}.html'>#{title} <span class='ui-li-count'>#{files.count}</span></li>"
end

def write_section_classification
  classification_list = write_classification("Secret - No Foreigners", "SECRET/NOFORN", "secret_noforn")
  classification_list << write_classification("Secret", "SECRET", "secret")
  classification_list << write_classification("Confidential - No Foreigners", "CONFIDENTIAL/NOFORN", "confidential_noforn")
  classification_list << write_classification("Confidential", "CONFIDENTIAL", "confidential")
  classification_list << write_classification("Unclassified - For official use only", "UNCLASSIFIED/FOR OFFICIAL USE ONLY", "unclassified_official_use_only")
  classification_list << write_classification("Unclassified", "UNCLASSIFIED", "unclassified")
  
  write_list("classification.html", classification_list, nil, false)
end

def write_release(title, folder, html, latest_update)
  files = Dir.glob(File.join($basedir, "/rel_date/#{folder}/*.txt"))
  latest_update[:count] = files.size if latest_update[:date].strftime("%Y/%m/%d") == folder
  files.each do |release|
    basename = File.basename(release)
    cable_list = ""
    files.each{|cable| cable_list << cable_list_item(File.basename(cable, ".txt"))}
    Dir.glob(File.join(release, "/*.txt")).each{|cable| cable_list << cable_list_item(File.basename(cable, ".txt"))}
    write_list("release/#{html}.html", cable_list, title, true)
  end
  "<li><a href='release/#{html}.html'>#{title} <span class='ui-li-count'>#{files.count}</span></li>"
end

def write_section_release(latest_update)
  release_list = ""
  Dir.glob(File.join($basedir, "/rel_date/*")).each do |year_folder|
    year = File.basename(year_folder)
    Dir.glob(File.join(year_folder, "*")).each do |month_folder|
      month = File.basename(month_folder)
      Dir.glob(File.join(month_folder, "*")).each do |day_folder|
        day = File.basename(day_folder)
        date = DateTime.parse("#{year}-#{month}-#{day}")
        if latest_update[:date].nil? || date > latest_update[:date]
          latest_update[:date] = date
          latest_update[:link] = "release/#{date.strftime("%Y_%m_%d")}.html"
        end
        release_list << write_release(date.strftime("%d %b %Y"), date.strftime("%Y/%m/%d"), date.strftime("%Y_%m_%d"), latest_update)
      end
    end
  end
  write_list("release.html", release_list, nil, false)
end

#
# Read files to complete metadata
#

Dir.glob(File.join($basedir, "/dates/*")).each do |year_folder|
  year = File.basename(year_folder)
  Dir.glob(File.join(year_folder, "*")).each do |month_folder|
    month = File.basename(month_folder)
    Dir.glob(File.join(month_folder, "*")) do |cable|
      title = ""
      tags = ""
      begin
          file = File.new(cable, "r")
          while title.empty? && tags.empty? && (line = file.gets)
            line.scan /^TAGS: (.*)\n/m do |extract|
              tags << extract.first
              line = file.gets
            end
            line.scan /^SUBJECT: (.*)\n/m do |extract|
              title << extract.first
              title << file.gets
              title.strip!
            end
          end
          file.close
      rescue => err
          puts "Exception: #{err}"
      end
      tags.split(" ").each do |tag|
        $tags << tag
      end
      $dated_cables[File.basename(cable, ".txt")] = {
        :date => "#{year}/#{month}",
        :title => title,
        :tags => tags
      }
    end
  end
end

#
# read files to write cables in mobile format
#

Dir.glob(File.join($basedir, "/cables/*")).each do |cable|
  content = ""
  cable_id = File.basename(cable, ".txt")
  begin
      file = File.new(cable, "r")
      while (line = file.gets)
        content << line << "<br>"
      end
      file.close
  rescue => err
      puts "Exception: #{err}"
  end
  write_cable(cable_id, content)
end

#
# Write indexes
#

latest_update = {:date => nil, :count => 0, :link => ""}

write_section_release(latest_update)
write_index(Dir.glob(File.join($basedir, "/cables/*.txt")).count, latest_update)
write_section_all
write_section_origin
write_section_classification