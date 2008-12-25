# Rakefile
require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('autonzb', '0.3') do |p|
  p.description    = "Ruby tool to automatically download x264 HD nzb movies files from newzleech.com"
  p.url            = "http://github.com/pirate/autonzb"
  p.author         = "Pirate"
  p.email          = "pirate.2061@gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.executable_pattern = "bin/autonzb"
  p.runtime_dependencies = ["hpricot", "optiflag", 'rubyzip', 'htmlentities']
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
