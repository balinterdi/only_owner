module OnlyOwner
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def only_owner
      before_filter :check_owner_access, :only => [:edit]
    end    
  end
  
  def check_owner_access
    # puts "XXX check_owner_access is called!!!"
    # respond with "Unauthorized"
    head(401) # to 
    # or halt_filter_chain? (see filters.rb in actionpack)
  end
  
end
