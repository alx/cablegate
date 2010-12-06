require 'date'

basedir = '.'

$dated_cables = {}
Dir.glob(File.join(basedir, "/dates")).each do |year|
  Dir.glob(File.join(basedir, year)).each do |month|
    Dir.glob(File.join(basedir, year, month)) do |cable|
      $dated_cables[File.basename(cable)] = "#{year}/#{month}"
    end
  end
end

def list_cables(title, files)
  cables_url = 'http://git.tetalab.org/index.php/p/cablegate/source/tree/master/cables'
  output = ""
  
  output << "\n<li>#{title} <span class='ui-li-count'>#{files.size}</span><ul>" unless title.empty?
  
  files.each do |file| 
    basename = File.basename(file)
    output << "\n<li><a href='#{$dated_cables[basename]}/#{basename}'>#{basename}</a></li>"
  end
  
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
  	  <div style='text-align:center'>
  	    <img src='./images/wikileaks.png' alt='wikileaks'/>
  	    <p>
  	    Currently released so far... <br>
  	    #{cable_count} / 251,287
  	    </p>
  	  </div>
  	
  		<ul data-role='listview' data-inset='true'> 
        <li><a href='./cables.html'>All cables</a> <span class='ui-li-count'>#{cable_count}</span></li>
        <li><a href='./classification.html'>By Classification</a></li>
        <li><a href='./date.html'>By Date</a></li>
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
write_list("cables.html", list_cables("", Dir.glob(File.join(basedir, "/cables/*.txt"))))

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
release_date = DateTime.parse("11/28/2010")
while release_date.strftime("%Y%m%d") != (Date.today + 1).strftime("%Y%m%d")
  cable_list << list_cables(release_date.strftime("%Y/%m/%d"), Dir.glob(File.join(basedir, "/rel_date/#{release_date.strftime("%Y/%m/%d")}/*.txt")))
  release_date += 1
end
write_list("release.html", cable_list)