require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require './app'
  end
  task :clean => :load_config do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  task :destroy => :load_config do
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.clean
  end
end
