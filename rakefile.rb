require 'sprout'
require 'doc/assets/ruby/help_builder'
require 'doc/assets/ruby/help_document'
# Load gems from a server other than rubyforge:
set_sources 'http://gems.gemcutter.org'
sprout 'as3'
sprout 'sprout-flexunit4as-library'

############################################
# Configure ProjectModel to be used by 
# script/generate for appropriate bundles.

project = project_model :model do |m|
  m.project_name            = 'Reprise'
  m.version                 = '0.5.5'
  m.language                = 'as3'
  m.doc_dir                  = "doc"
  m.doc_out                  = "#{m.doc_dir}/bin/asdoc"
end

############################################
# Configure CompilerModel to be shared with
# whichever tasks add it as a prerequisite.

tool_task_model :compiler_model do |m|
  m.source_path = []
  m.source_path << 'src'
  m.source_path << 'lib/penner_easing'
  m.source_path << 'lib/cinqetdemi_JSON'
  m.library_path = []
  m.library_path << 'lib'
  m.default_size = '970 550'
  m.default_background_color = '#ffffff'
  m.debug = true
end

############################################
# Configure :test
# http://projectsprouts.org/rdoc/classes/Sprout/MXMLCTask.html
# http://projectsprouts.org/rdoc/classes/Sprout/FlashPlayerTask.html

library :flexunit4as
library :flexunit4cilistener

mxmlc "bin/#{project.project_name}Runner.swf" => [:compiler_model, :flexunit4as] do |t|
  t.source_path << 'test'
  t.input = 'test/RepriseTestRunner.as'
end

desc 'Compile and debug the test harness'
flashplayer :test => "bin/#{project.project_name}Runner.swf"

#set :test as the default task
task :default => :test

############################################
# Configure :swc
# http://projectsprouts.org/rdoc/classes/Sprout/COMPCTask.html

compc "bin/#{project.project_name}_v#{project.version}.swc" => :compiler_model do |t|
  t.include_sources = []
  t.include_sources << 'src'
  t.include_libraries << 'lib/TrazzleCore.swc'
  t.include_libraries << 'lib/TrazzleLib.swc'
end

desc 'Compile the project as a SWC'
task :swc => "bin/#{project.project_name}_v#{project.version}.swc"

############################################
# Configure AsDoc
# http://projectsprouts.org/rdoc/classes/Sprout/AsDocTask.html

task :custom_docs do |t|
  builder = HelpBuilder.new("#{project.doc_dir}/src", 
    "#{project.doc_dir}/assets/templates")
  builder.render_to_path("#{project.doc_dir}/bin")
end

asdoc :doc => [:clean, :compiler_model, :custom_docs] do |t|
  t.doc_sources               << "src"
  t.output                    = project.doc_out
  t.templates_path            << 'doc/assets/templates/asdoc'
  t.window_title              = '"Reprise API Documentation"'
  t.main_title                = '"Reprise API Documentation"'
end

############################################
# Configure :cruise to compile and run
# test harness, then write results to disk
# and close the Flash Player.
#
# http://projectsprouts.org/rdoc/classes/Sprout/MXMLCTask.html
# http://projectsprouts.org/rdoc/classes/Sprout/FDBTask.html
#
# NOTE: The FDBTask cannot target a specific player, it 
# will launch whatever player is the default on your system.
# You may need to ensure your system default player is configured
# correctly.

mxmlc "bin/#{project.project_name}XMLRunner.swf" => [:compiler_model, :flexunit4as] do |t|
  t.source_path << 'test'
  t.input = 'test/RepriseTestRunner.as'
end

desc 'Compile and run the CI task'
fdb :cruise => "bin/#{project.project_name}XMLRunner.swf" do |t|
  t.file = "bin/#{project.project_name}XMLRunner.swf"
  t.kill_on_fault = true
  t.run
  # You can set breakpoints in here like:
  # t.break = 'SomeProjectXMLRunner:13'
  t.continue
end
