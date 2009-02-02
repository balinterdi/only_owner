$:.unshift(File.dirname(__FILE__) + '/../lib')
# RAILS_ROOT = File.dirname(__FILE__)

ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/test_process'
# require 'active_record'
require "#{File.dirname(__FILE__)}/../init"

# require 'rubygems'
# require 'active_support'
# require 'active_support/test_case'

begin
  require 'shoulda'
  require 'shoulda/active_record'
rescue LoadError => load_error
  $stderr.puts
  $stderr.puts "You need shoulda to run only_owner's tests. Do `gem install thoughtbot-shoulda` and try again."
  $stderr.puts
  exit
end

# begin
#   require 'mocha'
# rescue LoadError => load_error
#   $stderr.puts
#   $stderr.puts "You need mocha to run only_owner's tests. Do `gem install mocha` and try again."
#   $stderr.puts
#   exit
# end
