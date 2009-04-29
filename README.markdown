OnlyOwner
=========

The plugin aims to leverage the recurring theme of granting access only to the owner of a resource. (e.g a user profile). Most of the time all actions of a controller, except the new-create action and possibly the index and show actions should only be allowed for the owner.

The plugin provides an only_owner class method for ActionController which will deny access (redirect to the login page) to protected actions for non-owners. It does this through adding a before_filter to the chain.

The plugin supposes a few things about the available methods:

1. a current_user method is in scope in the controller and that it returns the currently active user of nil if no user is logged in. Another method can be given by passing the :current_user option.

2. a find_<model_name_singular> is in scope and it returns the model instance the user is fetching. This only makes sense for actions that operate on a given resource (edit, update, show, delete, destroy) but most of the time it is these actions that should be protected anyway. Another finder method can be used by specifying the :finder parameter.

3. the resource model has an association called "user" that links it to its owner. This name can be overridden by providing an :owner parameter which points.

The plugin supposes that all methods of the controller except the _new_, _create_, _index_ and _show_ ones need to be protected. If the actions to be protected differ from this, they can be specified with the following parameters:

    :only => actions : only the specified actions should be protected
    :except => actions: all actions except the specified actions should be protected

Examples
========

1. Profile belongs_to :user, there is a find_profile method in the controller, and the current_user method returns the user that is logged in:

    class ProfilesController < ApplicationController
      only_owner
    end

2. Profile belongs_to :user, there is a find_profile method in the controller, and the current_user method returns the user that is logged in. Only deletion is protected.

    class ProfilesController < ApplicationController
      only_owner :only => [:destroy]
    end

3. Same as 1., but the association linking the profile to the user is called _owner_

    class ProfilesController < ApplicationController
      only_owner :owner => :owner
    end

4. Same as 1., but the method returning the current user is _logged\_in\_user_

    class ProfilesController < ApplicationController
      only_owner :current_user => :logged_in_user, :owner => :owner
    end

5. Same as 1., but the method to find the profile is called _get\_profile_

    class ProfilesController < ApplicationController
      only_owner :finder => :get_profile
    end

Copyright (c) 2009 [Balint Erdi (balint@bucionrails.com)], released under the MIT license
