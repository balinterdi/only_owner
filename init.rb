require 'only_owner'

ActionController::Base.send(:include, OnlyOwner)
