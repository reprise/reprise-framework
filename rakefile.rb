require 'sprout'
require 'doc/assets/ruby/help_builder'
require 'doc/assets/ruby/help_document'

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
asdocdir = "#{model.doc_dir}/bin/asdoc"

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
  t.source_path               << 'lib/trazzle'
end

############################################
# Build documentation for your application

task :custom_docs do |t|
  builder = HelpBuilder.new("#{model.doc_dir}/src", 
    "#{model.doc_dir}/assets/templates")
  builder.render_to_path("#{model.doc_dir}/bin")
end

desc "Create documentation"
asdoc model.doc_dir => [:custom_docs] do |t|
  t.gem_name                  = 'sprout-flex3sdk-tool'
  t.output                    = asdocdir
  t.doc_sources               << model.src_dir
  t.doc_sources               << 'lib/trazzle'
  t.templates_path            << 'doc/assets/templates/asdoc'
  t.window_title              = '"Reprise API Documentation"'
  t.main_title                = '"Reprise API Documentation"'
end

desc "Deploy pre-generated documentation"
task :deploy_docs do |t|
  sh "rsync -r -v -delete --exclude=*.svn --exclude=.DS_Store --progress --rsh=ssh ./doc/bin/ ssh-959926-reprise@reprise-framework.org:doc/"
end

desc "Built and deploy documentation"
task :built_and_deploy_docs => [model.doc_dir, :deploy_docs]