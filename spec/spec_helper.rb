APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))
$: << File.join(APP_ROOT, "app")

require 'rspec'
require 'main'
