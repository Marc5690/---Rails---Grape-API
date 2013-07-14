class User < ActiveRecord::Base
  attr_accessible :age, :email, :enabled, :name 

has_many :microposts

has_many :comments
  has_many :commented_posts, :class_name => "Micropost" ,
           :through => :comments, :source => :micropost

  validates :name,  presence: true, length: { :maximum   => 20 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :age, presence: true, 
          :numericality => { :only_integer => true, 
                            :greater_than => 17 }
  validates :enabled, :inclusion => { :in => [true, false] }  

before_save do |user|
  user.email = email.downcase
  if !user.api_key
  user.api_key = SecureRandom.urlsafe_base64
else 
  
end
end

end