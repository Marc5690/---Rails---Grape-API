# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create some users
User.create(name:'joe bloggs', nickname:'joseph B', email:'jb@here.com', age: 22, enabled: true)
User.create(name:'joe Cloggs', nickname:'joey C', email:'jc@here.com', age: 32, enabled: true)
User.create(name:'jim smith', nickname:'jimmy S', email:'js@here.com', age: 24, enabled: true)

# Associate some microposts with users
user = User.find(1)
user.microposts.create(content: "Ruby is the best")
user.microposts.create(content: "Changed my mind, it's Java")
user = User.find(2)
user.microposts.create(content: "what Ruby lacks is ....")
user = User.find(3)
user.microposts.create(content: "I think Java and Ruby ....")

# Create some tags
ruby = Tag.create(name: 'Ruby')
java = Tag.create(name: 'Java')

# Associate some tags with microposts
Micropost.find(1).tags << ruby
Micropost.find(2).tags << java
Micropost.find(3).tags << ruby
Micropost.find(4).tags << ruby << java


# Add comments from users on microposts
comment = Comment.new(:content => "Great post")
comment.user = user
comment.micropost = Micropost.find(1)
comment.save

comment = Comment.new(:content => "I don't agree ...")
comment.user = user
comment.micropost = Micropost.find(2)
comment.save

comment = Comment.new(:content => "I don't agree either...")
comment.user = User.find(2)
comment.micropost = Micropost.find(2)
comment.save

