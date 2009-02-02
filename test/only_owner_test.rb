require File.dirname(__FILE__) + '/test_helper'

class OnlyOwnerTest < ActiveSupport::TestCase # Test::Unit::TestCase
  
  context "An only_owner enhanced controller" do
    setup do
      class User #< ActiveRecord::Base
        def name; end
      end
      
      class Profile #< ActiveRecord::Base
        def user; end
      end
      
      class ProfilesController < ActionController::Base
        
        def new; :new; end
        def create; :create; end
        def index; :index; end
        def edit; :edit; end
        def update; :update; end
        def destroy; :destroy; end
        def custom; :custom; end

      end
      
    end
    
    context "when no extra parameters are given" do
      setup do

        @controller = ProfilesController.new
        # class << @controller
        class ProfilesController
          only_owner
        end
        @request    = ActionController::TestRequest.new
        @response   = ActionController::TestResponse.new
        
        @user = User.new
        @another_user = User.new
        @profile = Profile.new
        @profile.stubs(:user).returns(@user)
      end
      
      context "when another user is logged in" do
        setup do
          ProfilesController.stubs(:current_user).returns(@another_user)
          # stub out choosing the route
          # ActionController::Routing::Routes.generate(:controller => 'profiles', :action => 'edit')
          # ActionController::Routing::Routes.stubs(:recognize_path).returns(:controller => 'profiles', :action => 'edit')
          #NOTE: the two stubs found below are needed for the routing to work
          #TODO: the two stubs could probably be replaced by defining a route 
          # as in routes.rb of a Rails app
          ActionController::Routing::Routes.stubs(:generate).returns("/profiles/edit")
          ActionController::Routing::Routes.stubs(:extra_keys).returns([])
          get :edit
        end
        
        should "not be able to access the edit action" do
          #TODO: check if unauthorized is available in Rails as a constant/symbol
          assert_response(401) 
        end
        
      end
        
    end # when no extra parameters are given
    
  end # "An only_owner enhanced controller"
  
end
