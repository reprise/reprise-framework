require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'rake/clean'
require 'flashsdk'
require 'asunit4'

version = '0.5.11'

##############################
# SWC

compc "bin/Reprise_v" + version + ".swc" do |t|
  t.source_path << 'src'
  t.source_path << 'lib/penner_easing'
  t.source_path << 'lib/cinqetdemi_JSON'
  t.library_path = []
  t.library_path << 'lib'
  t.include_sources = []
  t.include_sources << 'src'
  t.include_libraries << 'lib/TrazzleCore.swc'
  t.include_libraries << 'lib/TrazzleLib.swc'
end

desc "Compile the SWC file"
task :swc => "bin/Reprise_v" + version + ".swc"
