require File.dirname(__FILE__) + '/test_helper'

class OnlyOwnerTest < ActionController::TestCase
  
  context "An only_owner enhanced controller" do
    setup do
      class User #< ActiveRecord::Base
      end
      
      class Profile #< ActiveRecord::Base
        def owner; end
        def user; end
      end
      
      class ProfilesController < ActionController::Base

        def current_user; end
        def find_profile; end
        
        def new; render :text => "new" ; end
        def create; render :text => "create"; end
        def index; render :text => "index"; end
        def show; render :text => "show"; end
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

      Profile.any_instance.stubs(:user).returns(@user)
      ProfilesController.any_instance.stubs(:find_profile).returns(@profile)
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
            get :edit
          end
          should_redirect_to "login_path"
        end

        context "the update action" do
          setup do
            put :update, :id => 1
          end
          should_redirect_to "login_path"
        end
        
        context "the destroy action" do
          setup do
            delete :destroy, :id => 1
          end
          should_redirect_to "login_path"
        end

        context "a custom action" do
          setup do
            get :custom
          end
          should_redirect_to "login_path"
        end

        context "the new action" do
          setup do
            get :new
          end
          should_respond_with :success
        end

        context "the create action" do
          setup do
            post :create, :id => 1
          end
          should_respond_with :success
        end

        context "the index action" do
          setup do
            get :index
          end
          should_respond_with :success
        end
        
        context "the show action" do
          setup do
            get :show, :id => "1"
          end
          should_respond_with :success
        end
                
      end # when another user is logged in
      
      context "when the owner of the model/resource is logged in" do
        setup do
          ProfilesController.any_instance.stubs(:current_user).returns(@user)
        end
        context "any protected action" do
          context "like destroy" do
            setup do
              delete :destroy, :id => "1"
            end
            should_respond_with :success
          end
        end
      end # when the owner of the model/resource is logged in
      
    end # when no extra parameters are given
    
    context "when the default current_user method name is overridden" do
      setup do
        class ProfilesController
          def logged_in_user ; end
          only_owner :current_user => :logged_in_user
        end        
      end

      context "and the active user is other than the owner" do
        setup do
          # make sure the test breaks if the :current_user option is not taken into account
          ProfilesController.any_instance.stubs(:current_user).returns(@user)
          ProfilesController.any_instance.stubs(:logged_in_user).returns(@another_user)
        end
        context "a protected action" do
          setup do
            delete :destroy, :id => "1"
          end
          should_redirect_to "login_path"
        end

        context "the index action (an unprotected action)" do
          setup do
            get :index
          end
          should_respond_with :success
        end        
      end
      # TODO: write tests for when the current_user method is overridden and the active user is the owner
      # ...
    end
    
    # ----
    context "when the default owner method name is overridden" do
      setup do
        class Profile
          def user; end
        end
        class ProfilesController
          only_owner :owner => :owner
        end        
      end

      context "and the active user is other than the owner" do
        setup do
          # make sure the test breaks if the :owner option is not taken into account
          Profile.any_instance.stubs(:owner).returns(@user)
          Profile.any_instance.stubs(:user).returns(@another_user)
          ProfilesController.any_instance.stubs(:current_user).returns(@another_user)
        end
        context "a protected action" do
          setup do
            delete :destroy, :id => "1"
          end
          should_redirect_to "login_path"
        end

        context "the index action (an unprotected action)" do
          setup do
            get :index
          end
          should_respond_with :success
        end        
      end
      # TODO: write tests to make user the :user can still access the protected methods, too.
      # ...
    end
    # ----
    
    context "when the default finder method is overridden" do
      setup do
        class ProfilesController
          def get_profile; end
          only_owner :finder => :get_profile
        end
        # making find_profile return nil ensures that it does not get called
        # hmmm, mocking would be more appropriate, then.
        ProfilesController.any_instance.stubs(:current_user).returns(@another_user)
        
        ProfilesController.any_instance.stubs(:find_profile).returns(nil)
        ProfilesController.any_instance.stubs(:get_profile).returns(@profile)
        Profile.any_instance.stubs(:user).returns(@another_user)
        ProfilesController.any_instance.stubs(:current_user).returns(@user)                        
      end
      
      context "the destroy action" do
        setup do
          delete :destroy, :id => "1"
        end
        should_redirect_to "login_path"
      end
    
      context "the index action" do
        setup do
          get :index
        end
        should_respond_with :success
      end
    end # when the default owner method name is overridden
    
    context "when only certain actions are protected" do
      setup do
        class ProfilesController
          only_owner :only => [:destroy]          
        end        
      end
      context "the protected action(s)" do
        setup do
          delete :destroy, :id => 1
        end
        should_redirect_to "login_path"
      end
      context "all other actions" do
        context "e.g a custom action" do
          setup do
            get :custom, :id => 1
          end
          should_respond_with :success
        end
        context "e.g a create action" do
          setup do
            post :create
          end
          should_respond_with :success
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
