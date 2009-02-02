# Include hook code here
require 'only_owner'

ActionController::Base.send(:include, OnlyOwner)
