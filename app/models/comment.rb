class Comment < ActiveRecord::Base
  #attr_accessible :content, :micropost_id, :user_id

 attr_accessible :content  # CHANGED
   belongs_to :user         # NEW
   belongs_to :micropost    # NEW

   validate :content, presence: true
   validates :user_id, :micropost_id, presence: true, :numericality => { :only_integer => true }
   
#before_save do |comment|
#
#	if User.find_by_id(comment.user_id)
 #    comment.save
  #   #error!("The user does not exist", 404)
#	else
#    self.delete#
#	end
#end
end
