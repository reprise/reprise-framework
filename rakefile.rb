require 'sprout'
# Optionally load gems from a server other than rubyforge:
# set_sources 'http://gems.projectsprouts.org'
sprout 'as3'

############################################
# Uncomment and modify any of the following:
Sprout::ProjectModel.setup do |model|
  model.project_name  = 'Reprise Framework'
  model.language      = 'as3'
  model.test_output   = "#{model.bin_dir}/RepriseTestRunner.swf"
end

model = Sprout::ProjectModel.instance

library :asunit3

task :default => :test

desc "Compile and run test suites"
flashplayer :test => model.test_output

desc "Compile test harness"
mxmlc model.test_output => [:asunit3] do |t|
  t.gem_name                  = 'sprout-flex3sdk-tool'
  t.warnings                  = true
  t.default_background_color  = '#FFFFFF'
  t.default_frame_rate        = 24
  t.verbose_stacktraces       = true
  t.default_size              = "800 450"
  t.input                     = "#{model.test_dir}/RepriseTestRunner.as"
  t.source_path               << model.src_dir
  t.source_path               << model.test_dir
end

############################################
# Build documentation for your application

desc "Create documentation"
asdoc model.doc_dir do |t|
# Uncomment to use the Flex 3 SDK
  t.gem_name                  = 'sprout-flex3sdk-tool'
  t.doc_sources               << model.src_dir
  t.window_title              = '"Reprise API Documentation"'
  t.main_title                = '"Reprise API Documentation"'
end