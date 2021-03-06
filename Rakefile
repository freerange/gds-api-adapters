# -*- encoding: utf-8 -*-

require "rdoc/task"
require 'rake/testtask'

RDoc::Task.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

Rake::TestTask.new("test") do |t|
  t.ruby_opts << "-rubygems"
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end
task :default => :test

require 'pact_broker/client/tasks'

def configure_pact_broker_location(task)
  task.pact_broker_base_url = ENV.fetch("PACT_BROKER_BASE_URL")
  if ENV['PACT_BROKER_USERNAME']
    task.pact_broker_basic_auth =  { username: ENV['PACT_BROKER_USERNAME'], password: ENV['PACT_BROKER_PASSWORD']}
  end
end

PactBroker::Client::PublicationTask.new("branch") do | task |
  task.consumer_version = ENV.fetch("PACT_TARGET_BRANCH")
  configure_pact_broker_location(task)
end

PactBroker::Client::PublicationTask.new("released_version") do | task |
  require 'gds_api/version'
  task.consumer_version = GdsApi::VERSION
  configure_pact_broker_location(task)
end

require "gem_publisher"
desc "Publish gem to rubygems.org if necessary"
task :publish_gem do |t|
  gem = GemPublisher.publish_if_updated("gds-api-adapters.gemspec", :rubygems)
  if gem
    puts "Published #{gem}"

    Rake::Task["pact:publish:released_version"].invoke
  end
end
