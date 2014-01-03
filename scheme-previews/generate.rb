
# Parse args to get name of colour scheme
if ARGV.length == 1
  scheme = ARGV[0]
else
  puts "Usage: #$0 color-scheme"
  exit 1
end

# Identify scheme name and filename
if scheme =~ /^(.*?\/)?([^\/]+)\.clr$/i
  srcfile = scheme
  scheme = $2
else
  srcfile = "#{scheme}.clr"
end
mapfile = "svg/#{scheme}.svg"

# Check that the colour file exists
unless File.exist? srcfile
  puts "Could not find '#{srcfile}'"
  exit 2
end

# Read from the colour file
src = File.open(srcfile, 'r') { |f| f.read }
if !src or src.empty?
  puts "Could not read '#{srcfile}' or file is empty"
  exit 2
end

# Extract colours from the colour file
src.gsub! %r(\s*//.*), ''
colours = src.scan /(\d{1,3}),(\d{1,3}),(\d{1,3})/

# Ensure there are the right number of colours
if !colours or colours.length < 71
  puts "Doesn't appear to be a valid colour file (found #{colours.length} colours, expected 71)"
  exit 2
end

# Turn them into CSS colours
colours.map! do |x|
  x.map! {|y| y.to_i }
  '#%02x%02x%02x' % x
end

# Generate CSS
css = "<style type=\"text/css\" id=\"scheme\"><![CDATA[
      .background {
        fill: #{colours[0]};
      }
      .motorway {
        fill: #{colours[21]};
        stroke: #{colours[20]};
      }
      .park {
        fill: #{colours[3]};
      }
      .water {
        fill: #{colours[2]};
      }
      .railroad {
        fill: #{colours[49]};
      }
      .railroadB {
        fill: #{colours[50]};
      }
      .city {
        fill: #{colours[1]};
      }
      .unreachable {
        fill: #{colours[18]};
      }
      .destination {
        fill: #{colours[42]};
        stroke: #{colours[41]};
      }
      .connecting {
        fill: #{colours[36]};
        stroke: #{colours[35]};
      }
      .major {
        fill: #{colours[26]};
        stroke: #{colours[24]};
      }
      .arrows {
        fill: #{colours[53]};
        stroke: #{colours[54]};
      }
    ]]></style>"

# Hacky fart blugg
map = File.open('map.svg', 'r'){|f|f.read}
map.gsub! %r|(<style type="text/css" id="scheme">.*?</style>)|m, css

File.open(mapfile,'w') { |f| f.write map }
