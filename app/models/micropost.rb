class Micropost < ActiveRecord::Base
 attr_accessible :content, :user_id

  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :comments
  has_many :commentators, :through => :comments,
            :source => :user

  validates :content,  presence: true
   validates :user_id, presence: true, :numericality => { :only_integer => true }
#before_save do |post|
#	if User.find_by_id(:user_id)
 #    post.save
     #error!("The user does not exist", 404)
	#else
 #   self.delete
#	end
#end
end
