require 'date'

basedir = '.'

$dated_cables = {}
Dir.glob(File.join(basedir, "/dates/*")).each do |year_folder|
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
      
      $dated_cables[File.basename(cable, ".txt")] = {
        :date => "#{year}/#{month}",
        :title => title,
        :tags => tags
      }
    end
  end
end

def cable_list_item(basename)
  cables_url = 'http://www.wikileaks.ch/cable'
  cable_data = $dated_cables[basename]
  output = "\n<li><h3><a href='#{cables_url}/#{cable_data[:date]}/#{basename}.html'>#{cable_data[:title]}</a></h3>"
  output << "<p>Tags: #{cable_data[:tags]}</p>" unless cable_data[:tags].empty?
  output << "<p class='ui-li-aside'>#{basename}</p></li>"
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

def write_index(cable_count)
  index_content = "
  <div data-role='page'> 
  	<div data-role='header'> 
  		<h1>Wikileaks CableGate</h1> 
  	</div><!-- /header --> 

  	<div data-role='content'>
  	  <div style='text-align:center'><img src='./images/wikileaks.png' alt='wikileaks'/></div>
  	
  		<ul data-role='listview' data-inset='true'> 
        <li><a href='./cables.html'>All cables</a> <span class='ui-li-count'>#{cable_count}</span></li>
        <li><a href='./classification.html'>By Classification</a></li>
        <li><a href='./origin.html'>By Origin</a></li>
        <li><a href='./release.html'>By Release</a></li>
      </ul>
  	</div><!-- /content --> 
  </div><!-- /page -->"
  write_html("index.html", index_content)
end

def write_list(filename, list)
  content = "
  <div data-role='page'> 
  	<div data-role='header'> 
  		<h1>Wikileaks CableGate</h1> 
  	</div><!-- /header --> 

  	<div data-role='content'> 
  		<ul data-role='listview'> 
        #{list}
      </ul>
  	</div><!-- /content --> 
  </div><!-- /page -->"
  write_html(filename, content)
end

# Write index
write_index(Dir.glob(File.join(basedir, "/cables/*.txt")).count)

# List all cables
# write_list("cables.html", list_cables("", Dir.glob(File.join(basedir, "/cables/*.txt"))))
cable_list = ""
Dir.glob(File.join(basedir, "/dates/*")).each do |year_folder|
  year = File.basename(year_folder)
  Dir.glob(File.join(year_folder, "*")).each do |month_folder|
    month = File.basename(month_folder)
    cable_list << "<li data-role='list-divider'>#{DateTime.parse("#{year}-#{month}-01").strftime("%b %Y")} <span class='ui-li-count'>#{Dir.glob(File.join(month_folder, "*")).count}</span></li>"
    Dir.glob(File.join(month_folder, "*")) do |cable|
      cable_list << cable_list_item(File.basename(cable, ".txt"))
    end
  end
end
write_list("cables.html", cable_list)

# List origin
cable_list = ""
Dir.glob(File.join(basedir, "/origin/*")).each do |origin|
  cable_list << list_cables(File.basename(origin), Dir.glob(File.join(origin, "*.txt")))
end
write_list("origin.html", cable_list)

# List classification
cable_list = ""
cable_list << list_cables("Secret - No Foreigners", Dir.glob(File.join(basedir, "/classification/SECRET/NOFORN/*.txt")))
cable_list << list_cables("Secret", Dir.glob(File.join(basedir, "/classification/SECRET/*.txt")))
cable_list << list_cables("Confidential - No Foreigners", Dir.glob(File.join(basedir, "/classification/CONFIDENTIAL/NOFORN/*.txt")))
cable_list << list_cables("Confidential", Dir.glob(File.join(basedir, "/classification/CONFIDENTIAL/*.txt")))
cable_list << list_cables("Unclassified - For official use only", Dir.glob(File.join(basedir, "/classification/UNCLASSIFIED/FOR OFFICIAL USE ONLY/*.txt")))
cable_list << list_cables("Unclassified", Dir.glob(File.join(basedir, "/classification/UNCLASSIFIED/*.txt")))
write_list("classification.html", cable_list)

# List release dates
cable_list = ""
Dir.glob(File.join(basedir, "/rel_date/*")).each do |year_folder|
  year = File.basename(year_folder)
  Dir.glob(File.join(year_folder, "*")).each do |month_folder|
    month = File.basename(month_folder)
    Dir.glob(File.join(month_folder, "*")).each do |day_folder|
      day = File.basename(day_folder)
      cable_list << list_cables("#{DateTime.parse("#{year}-#{month}-#{day}").strftime("%d %b %Y")}", Dir.glob(File.join(day_folder, "*")))
    end
  end
end
write_list("release.html", cable_list)