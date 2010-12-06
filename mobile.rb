require 'date'

basedir = '.'

def list_cables(title, files)
  cables_url = 'http://git.tetalab.org/index.php/p/cablegate/source/tree/master/cables'
  output = "\n<li>#{title} <span class='ui-li-count'>#{files.size}</span><ul>"
  
  files.each do |file| 
    basename = File.basename(file)
    output << "\n<li><a href='#{cables_url}/#{basename}'>#{basename}</a></li>"
  end
  
  output << "\n</ul></li>"
  output
end

# List all cables
cable_list = list_cables("All Cables", Dir.glob(File.join(basedir, "/cables/*.txt")))

# List classification
cable_list << "\n<li>By Classification <ul>"

cable_list << list_cables("Secret - No Foreigners", Dir.glob(File.join(basedir, "/classification/SECRET/NOFORN/*.txt")))
cable_list << list_cables("Secret", Dir.glob(File.join(basedir, "/classification/SECRET/*.txt")))
cable_list << list_cables("Confidential - No Foreigners", Dir.glob(File.join(basedir, "/classification/CONFIDENTIAL/NOFORN/*.txt")))
cable_list << list_cables("Confidential", Dir.glob(File.join(basedir, "/classification/CONFIDENTIAL/*.txt")))
cable_list << list_cables("Unclassified - For official use only", Dir.glob(File.join(basedir, "/classification/UNCLASSIFIED/FOR OFFICIAL USE ONLY/*.txt")))
cable_list << list_cables("Unclassified", Dir.glob(File.join(basedir, "/classification/UNCLASSIFIED/*.txt")))

cable_list << "\n</ul></li>"

# List origin
cable_list << "\n<li>By Origin <ul>"
Dir.glob(File.join(basedir, "/origin/*")).each do |origin|
  cable_list << list_cables(File.basename(origin), Dir.glob(File.join(origin, "*.txt")))
end
cable_list << "\n</ul></li>"

# List release dates
cable_list << "\n<li>By Release Date <ul>"
release_date = DateTime.parse("11/28/2010")
while release_date.strftime("%Y%m%d") != (Date.today + 1).strftime("%Y%m%d")
  cable_list << list_cables(release_date.strftime("%Y/%m/%d"), Dir.glob(File.join(basedir, "/rel_date/#{release_date.strftime("%Y/%m/%d")}/*.txt")))
  release_date += 1
end
cable_list << "\n</ul></li>"

File.open("mobile.html", "w") do |f|
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
    <div data-role='page'> 

    	<div data-role='header'> 
    		<h1>Wikileaks CableGate</h1> 
    	</div><!-- /header --> 

    	<div data-role='content'> 
    		<ul data-role='listview'> 
          #{cable_list}
        </ul>
    	</div><!-- /content --> 
    </div><!-- /page -->
  </body> 
  </html>"
end
