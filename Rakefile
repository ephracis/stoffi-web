# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require File.expand_path('../config/application', __FILE__)
require "yard"
require "yard/rake/yardoc_task"

Rails.application.load_tasks

task default: [:test, :teaspoon]

YARD::Rake::YardocTask.new do |t|
  t.files   = ['app/**/*.rb']
  t.options = ['--markup=markdown', '--title', 'Stoffi Documentation']
  t.stats_options = ['--list-undoc']
end