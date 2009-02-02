require File.dirname(__FILE__) + '/test_helper'

class OnlyOwnerTest < ActiveSupport::TestCase # Test::Unit::TestCase
  
  context "An only_owner enhanced controller" do
    setup do
      class User #< ActiveRecord::Base
      end
      
      class Profile #< ActiveRecord::Base
        def owner; end
      end
      
      class ProfilesController < ActionController::Base

        def current_user; end
        def find_profile; end
        
        def new; render :text => "new" ; end
        def create; render :text => "create"; end
        def index; render :text => "index"; end
        def edit; render :text => "edit"; end
        def update; render :text => "update"; end
        def destroy; render :text => "destroy"; end
        def custom; render :text => "custom"; end

      end
      
      @controller = ProfilesController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      
      @user = User.new
      @another_user = User.new
      @profile = Profile.new

      Profile.any_instance.stubs(:owner).returns(@user)
      ProfilesController.any_instance.stubs(:find_profile).returns(@profile)

      # ActionController::Routing::Routes.generate(:controller => 'profiles', :action => 'edit')
      # ActionController::Routing::Routes.stubs(:recognize_path).returns(:controller => 'profiles', :action => 'edit')        
      #NOTE: the two stubs found below are needed for the routing to work
      # the two stubs: extra_keys and generate
      #TODO: the two stubs could probably be replaced by defining a route 
      # as in routes.rb of a Rails app        
      # ActionController::Routing::Routes.stubs(:generate).returns("/profiles/edit")
      ActionController::Routing::Routes.stubs(:extra_keys).returns([])
      
    end
    
    context "when no extra parameters are given" do
      setup do
        class ProfilesController
          only_owner
        end
        
      end
      
      context "when another user is logged in" do
        setup do
          ProfilesController.any_instance.stubs(:current_user).returns(@another_user)
        end
        
        context "the edit action" do
          setup do
            ActionController::Routing::Routes.stubs(:generate).returns("/profiles/1/edit")
            get :edit
          end
          should "be protected" do
            assert_response(401)
          end
        end

        context "the update action" do
          setup do
            ActionController::Routing::Routes.stubs(:generate).returns("/profiles/1/update")
            put :update, :id => 1
          end
          should "be protected" do
            assert_response(401)
          end
        end
        
        context "the destroy action" do
          setup do
            ActionController::Routing::Routes.stubs(:generate).returns("/profiles/1/destroy")
            delete :destroy, :id => 1
          end
          should "be protected" do
            assert_response(401)
          end
        end

        context "a custom action" do
          setup do
            ActionController::Routing::Routes.stubs(:generate).returns("/profiles/custom")
            get :custom
          end
          should "be protected" do
            assert_response(401)
          end
        end

        context "the new action" do
          setup do
            ActionController::Routing::Routes.stubs(:generate).returns("/profiles/new")
            get :new
          end
          should "be accessible" do
            assert_response(200)
          end
        end

        context "the create action" do
          setup do
            ActionController::Routing::Routes.stubs(:generate).returns("/profiles/2/create")
            post :create, :id => 1
          end
          should "be accessible" do
            assert_response(200)
          end
        end

        context "the index action" do
          setup do
            ActionController::Routing::Routes.stubs(:generate).returns("/profiles/")
            get :index
          end
          should "be accessible" do
            assert_response(200)
          end
        end
                
      end # when another user is logged in
      
      context "when the owner of the model/resource is logged in" do
        setup do
          ProfilesController.any_instance.stubs(:current_user).returns(@user)
        end
        context "any protected action" do
          context "like destroy" do
            setup do
              ActionController::Routing::Routes.stubs(:generate).returns("/profiles/1/destroy")
              delete :destroy, :id => "1"
            end
            should "be accessible" do
              assert_response(200)
            end
          end
        end
      end # when the owner of the model/resource is logged in
      
    end # when no extra parameters are given
    
    context "when only certain actions are protected" do
      setup do
        class ProfilesController
          only_owner :only => [:destroy]          
        end        
      end
      context "the protected action(s)" do
        setup do
          ActionController::Routing::Routes.stubs(:generate).returns("/profiles/1/destroy/")
          delete :destroy, :id => 1
        end
        should "be protected" do
          assert_response(401)
        end
      end
      context "all other actions" do
        context "e.g a custom action" do
          setup do
            ActionController::Routing::Routes.stubs(:generate).returns("/profiles/1/custom/")
            get :custom, :id => 1
          end
          should "be accessible" do
            assert_response(200)
          end
        end
        context "e.g a create action" do
          setup do
            ActionController::Routing::Routes.stubs(:generate).returns("/profiles/create/")
            post :create
          end
          should "be accessible" do
            assert_response(200)
          end
        end
        
      end # all other actions
      
    end # when only certain actions are protected
    context "when certain actions are specified as not protected" do
      setup do
        class ProfilesController
          only_owner :exclude => [:index]
        end
        #TODO: tests to be added here
      end
    end # "when certain actions are specified as not protected"
    
  end # "An only_owner enhanced controller"
  
end
