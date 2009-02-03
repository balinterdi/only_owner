module OnlyOwner
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def only_owner(options={})
      # def append_before_filter(*filters, &block)
      #   filter_chain.append_filter_to_chain(filters, :before, &block)
      # end
      # XXX append_before_filter filters: [:find_project, {:except=>[:index, :user]}]
      # store non-before filter parameters in class variables
      # so they can be gotten back in check_owner access
      cattr_accessor :only_owner_current_user
      
      self.only_owner_current_user = options[:current_user] || :current_user
      options[:except] = [:new, :create, :index] unless options[:only] || options[:except]
      before_filter :check_owner_access, options
    end    
  end
  
  def check_owner_access
    model_class = self.controller_name.singularize
    model_instance = send("find_#{model_class}", params[:id])
    owner = model_instance.send(:owner)
    current_user_ = send(self.class.only_owner_current_user)
    head(401) unless current_user_ == owner
    # or halt_filter_chain? (see filters.rb in actionpack)
  end
  
end
