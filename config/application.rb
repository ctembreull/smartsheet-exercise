$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'

Bundler.require :default, ENV['RACK_ENV']
application_paths = %w(
  ../../config/initializers/*.rb,
  ../../models/*.rb
)

application_paths.each do |path|
  Dir[File.expand_path(path, __FILE__)].each { |f| require f }
end
