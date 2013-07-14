require 'grape'

module Blog

#class API < Grape::API

  #mount Blog::API1
  #mount Blog::API2

  # end
#end
   class API1 < Grape::API
	format :json

version 'v1', :using => :path

rescue_from Grape::Exceptions::Validation do |e|
    Rack::Response.new({
        'status' => e.status,
        'message' => e.message,
        'param' => e.param
    }.to_json, e.status)
end

#Content-Type: application/json



 # rescue_from Grape::Exceptions::ValidationError do |e|
 #   Rack::Response.new({
 #       'status' => e.status,
 #       'message' => e.message,
 #       'param' => e.param
 #   }.to_json, e.status)
 # end

 #version 'v2', :using => :param
 #http://localhost:3000/api/v1/users

 
 helpers do
  
  def authenticate_user(user, api_key)
     @user = User.find_by_id(user)#user)#User.all
      if @user.api_key == (api_key)#api_key #&& f.id == params#AND
         return true
      else
        return false
      #error!("User with id:#{user} could not be authenticated with the api key:#{api_key}", 401)
      end
  end

  def userexists(id)
    if User.exists?(:id=>id)
      return true
    else 
      error!("The user with id:#{id} does not exist.", 404)
    end
  end

  def postexists(id)
    if Micropost.exists?(:id=>id)
      return true
    else 
      error!("The micropost with id:#{id} does not exist.", 404)
    end
  end

  def tagexists(id)
    if Tag.exists?(:id=>id)
      return true
    else 
      error!("The tag with id:#{id} does not exist.", 404)
    end
  end

  def commentexists(id)
    if Comment.exists?(:id=>id)
      return true
    else 
      error!("The comment with id:#{id} does not exist.", 404)
    end
  end

 end#end helpers

#######################################################################

  resource :users do
    #http://localhost:3000/api/v2/users/4/mh0atFTL-WVOX6JTlyQuQg/posts

    desc "Gets all users."
	  get do 
      if params['type'] == 'latest'#Gets latest user
                  User.order("created_at DESC")[0]
                  #Gets all users who have no Microposts
              elsif params['type'] == 'empty'
                  User.all.select {|w| w.microposts.count == 0}
                  #Gets user with highest age
              elsif params['type'] == 'oldest'
                  User.all.max_by(&:age)
                  #Gets user with most microposts
              elsif params['type'] == 'posts'
                  User.all.select.max_by {|w| w.microposts.count}
              else
                  User.all
              end
    end#End endpoint



    get 'identities' do#Get all existing names and id's
       identity = User.all
       identity.to_json(:only => [ :id, :name ])
    end#End endpoint

    get 'identifications' do#Get all existing id's
       identification = User.all
       identification.to_json(:only => [ :id])
    end#End endpoint
    
    namespace do#start namespace scope requires :id, type: Integer
    params do
       requires :id, type: Integer
    end#End params

	  get ':id' do#Get a user
      if User.exists?(:id=>params[:id]) && params['type'] == 'name'   #Gets latest user
        @user = (User.find(params[:id]))
        @user.to_json(:only => [:name])
      elsif User.exists?(:id=>params[:id]) && params['type'] == 'age' 
        @user = (User.find(params[:id]))
        @user.to_json(:only => [:age])
      elsif User.exists?(:id=>params[:id])
        @user = (User.find(params[:id]))
        @user
      elsif !User.exists?(:id=>params[:id])
        error!("User does not exist!", 404)
      else
        error!("Unknown error", 400)
       #  @user.to_json(:only => [:id]) 
        #else#if params['type'] == 'id'      
         #@user = (User.find(params[:id]))
         #exists @user
         #@user #if exists @user 
       #end
       # end
      end
       #end#End exists
	  end#End endpoint

	  get ':id/microposts' do#Get all of a users microposts
       if userexists params[:id]
        @user = User.find(params[:id])
        @user.microposts
       end
    end#End endpoint

    get ':id/comments' do#Get all of a users microposts
       if userexists params[:id]
        user = User.find(params[:id]) 
        user.comments
       end
    end#End endpoint
    
    #AUTHORIZATION REQUIRED
    delete ':id/posts/:api_key' do#Delete all of a users microposts
      if userexists params[:id]
       user = params[:id]
       api_key = params[:api_key]
        if authenticate_user user, api_key
           @user = User.find(params[:id])
           @user.microposts.each do |f|
           f.destroy()
           end
        else
           error!("Could not authenticate user", 401)
        end
      end
    end#End endpoint

    #Delete all of a users comments
    #AUTHORIZATION REQUIRED
    delete ':id/comments/:api_key' do
       if userexists params[:id]
       user = params[:id]
       api_key = params[:api_key]
        if authenticate_user user, api_key
           @user = User.find(params[:id])
           @user.comments.each do |f|
           f.destroy()
           end
        else
           error!("Could not authenticate user", 401)
        end
      end
    end#End endpoint
    end#End namespace requires :id, type: Integer


   

 params do
       requires :content
       requires :micropost_id, type: Integer
       requires :id, type: Integer
        end

  
    #Create a comment for a user
    #AUTHORIZATION WORKS
    post ':id/:api_key/comment' do
       user = params[:id]##Meant to be number
       api_key = params[:api_key]
       if userexists user
        if authenticate_user user, api_key
           @comment = Comment.new
           @comment.content = params[:content] #if params[:content]
           @comment.user_id = params[:id] #if params[:user_id]
           @comment.micropost_id = params[:micropost_id] #if params[:micropost_id]
           status 201
           @comment.save
           @comment
        else
           error!('401 Unauthorized', 401) 
        end
      end
    end#End endpoint


 params do###Only for endpoint below, does not require namespace as this is the only endpoint that requires both an id and content as parameters
       requires :content
       requires :id, type: Integer
    end#End params

    #Create a post for a user
    #AUTHORIZATION REQUIRED
    post ':id/:api_key/posts' do
         user = params[:id]
         api_key = params[:api_key] 
         if userexists user
         if authenticate_user user, api_key
          
         @user = User.find(params[:id])
          @micropost = @user.microposts.create(content: params[:content], 
                                         user_id: params[:id])
        
         else 
           
          error!('User could not be authenticated with the api key provided', 401) 
     
    end
      end
    end#End endpoint


    namespace do#start namespace scope  requires :name, :email, :enabled and :age(type: Integer)
    params do
       requires :name
       requires :email
       requires :enabled
       requires :age, type: Integer
    end#End params

    #AUTHORIZATION WORKS
    put ':user/:api_key' do#Update a user
       
       user = params[:user] 
       api_key = params[:api_key]
       if userexists user
        @user = User.find(params[:user])
        if authenticate_user user, api_key#api_key])
           @user.name = params[:name] #if params[:name]
           @user.email = params[:email]# if params[:email]
           @user.enabled = params[:enabled]# if params[:enabled]
           @user.age = params[:age]# if params[:age]
           @user.save
           @user
        else 
           error!('401 Unauthorized', 401) 
        end
      end
    end#End endpoint

	  post do#Create a new user
		   @user = User.new
       @user.name = params[:name]
       @user.email = params[:email] 
       @user.enabled = params[:enabled] 
       @user.age = params[:age] 
       @user.save
       @user
	  end#End endpoint
    end#End namespace requires :name, :email, :enabled and :age(type: Integer)
  end#End users resource

#######################################################################

  resource :microposts do
    # Get all Microposts
    get do
       Micropost.all
    end

    get 'identification' do#Get all existing id's
       identification = Micropost.all
       identification.to_json(:only => [ :id])
    end#End endpoint

   namespace do#start namespace scope requires :id, type: Integer
    params do
       requires :id, type: Integer
    end#End params

    get ':id/comments' do#Get all of a microposts comments 
      if postexists params[:id]
       micropost = Micropost.find(params[:id])
       micropost.comments
     end
    end

    #Get a micropost
    get ':id' do

      
      if postexists params[:id]
        @post = Micropost.find(params[:id])
        @post
      end
    end#End endpoint
       

    #Delete all of a Microposts comments
    
    #AUTHORIZATION REQUIRED
    #delete ':id/comments' do
    #   @post = Micropost.find(params[:id])
    #   @post.comments.clear
    #end#End endpoint

    #Delete a Micropost
    #AUTHORIZATION REQUIRED
    delete ':id/:api_key' do
      if postexists params[:id]
       post = Micropost.find_by_id(params[:id])##Meant to be number
       user = post.user.id
       api_key = params[:api_key]
        if authenticate_user user, api_key
           @post = Micropost.find(params[:id])
           @post.destroy()
        else
           error!('401 Unauthorized', 401) 
        end
      end
    end#End endpoint

    end#End namespace scope requires :id, type: Integer
  end#End micropost resource

#######################################################################

  resource :tags do 
     #Get all tags
     get do
        Tag.all
     end#End endpoint

     get 'identification' do#Get all existing id's
       identification = Tag.all
       identification.to_json(:only => [ :id])
    end#End endpoint

     namespace do#start namespace scope requires :id, type: Integer
     params do
        requires :id, type: Integer
     end#End params

     #Get a tag
     get ':id' do 
      if tagexists params[:id]
        @tag = Tag.find(params[:id])
        @tag
      end
     end#End endpoint

     #Get microposts by their tags
     get ':id/posts' do
      if tagexists params[:id]
       @tag = Tag.find(params[:id])
       @tag.microposts
      end
     end#End endpoint
     end#End namespace scope requires :id, type: Integer
    
     params do###Only for endpoint below
        requires :name
     end

     #Create a new tag
     post  do
        @tag = Tag.new
        @tag.name = params[:name] if params[:name]
        @tag.save
        status 201
     end 
 
     params do#Only for endpoint below
         requires :tag_id, type: Integer
         requires :micropost_id, type: Integer
     end#End params

     #Tag a micropost
     post ':tag_id/:micropost_id'do
     if tagexists params[:tag_id]
        @tag = Tag.find_by_id(params[:tag_id])
        if postexists params[:micropost_id]
        @micropost = Micropost.find_by_id(params[:micropost_id])
        @micropost.tags << @tag
   else
    error!("Post could not be found", 404)
   end
     end
   end
  end#end tags resource

#######################################################################

  resource :comments do

    #Get all comments - 
    get 'api/comments' do
       Comment.all
    end

    get 'identification' do#Get all existing id's
       identification = Comment.all
       identification.to_json(:only => [ :id])
    end#End endpoint

   
 
    #Delete all comments - 
   # delete 'api/comments' do
   #    Comment.destroy_all()
   # end

    namespace do#Namespace scope for requires :id, type: Integer
    params do
       requires :id, type: Integer
    end

    #Get a specific comment
    get ':id' do
      if commentexists params[:id]
       Comment.find(params[:id])
     end
    end#End endpoint

    #AUTHORIZATION REQUIRED
    delete ':id/:api_key' do
      if commentexists params[:id]
       @comment = Comment.find(params[:id])
       user = @comment.user.id
       api_key = params[:api_key]
        if authenticate_user user, api_key
           @comment.destroy()
        else
           error!("Unauthorized user!", 401)
        end
      end
    end#End endpoint
    end#End namespace scope for requires :id, type: Integer
  end#End comments resource
end#End class
















class API2 < Grape::API
  format :json
  
  version 'v2', :using => :path
  rescue_from :all do |e|
    rack_response({ :message => "rescued from #{e.class.name}" })
  end


 
#http://localhost:3000/api/users?apiver=v1
#http://localhost:3000/api/users?apiver=v2
 helpers do

 def authenticate_user(user, api_key)
  @user = User.find_by_id(user)#user)#User.all
   #@user do |f|
   if @user.api_key == (api_key)#api_key #&& f.id == params#AND
status 200
return true
else
 return false
#  if user.find(params[:id]).api_key == (params[:api_key])
end
end 
end
 #end



  resource :users do

    get do#Get all users
      if params['type'] == 'latest'#Gets latest user
                  User.order("created_at DESC")[0]
                  #Gets all users who have no Microposts
              elsif params['type'] == 'empty'
                  User.all.select {|w| w.microposts.count == 0}
              else
                  User.all
              end
    end  # endpoint

          

    get ':id' do#Get a user
            User.find(params[:id])
    end

    get ':id/microposts' do#Get all of a users microposts
        user = User.find(params[:id])
        user.microposts
    end

    get ':id/comments' do#Get all of a users microposts
        user = User.find(params[:id])
        user.comments
    end

#AUTHORIZATION WORKS
    put ':user/:api_key' do#Update a user
        @user = User.find(params[:user])
        user = params[:user] 
        api_key = params[:api_key]
        if authenticate_user user, api_key#api_key])
           @user.name = params[:name] if params[:name]
           @user.email = params[:email] if params[:email]
           @user.enabled = params[:enabled] if params[:enabled]
           @user.age = params[:age] if params[:age]
           @user.save
           @user
        else 
           error!('401 Unauthorized', 401) 

        end
    end
     

    #AUTHORIZATION WORKS
    delete ':id/posts/:api_key' do#Delete all of a users microposts
    user = params[:id]##Meant to be number
    api_key = params[:api_key]
    if authenticate_user user, api_key
     @user = User.find(params[:id])
     @user.microposts.each do |f|

     f.destroy()#Clear only sets user_id to nil
     end
    else
     error!("Could not authenticate user", 401)
    end
    end

    #AUTHORIZATION
    delete ':id/comments/:api_key' do#Delete all of a users comments
    
    user = params[:id]##Meant to be number
    api_key = params[:api_key]
    if authenticate_user user, api_key
    @user = User.find(params[:id])
    @user.comments.each do |f|
      f.destroy()
    end
  else
error!("Could not authenticate user", 401)
  end
    end

    post do#Create a new user
    @user = User.new
    @user.name = params[:name] if params[:name]
    @user.email = params[:email] if params[:email]
    @user.enabled = params[:enabled] if params[:enabled]
    @user.age = params[:age] if params[:age]
    @user.save
    status 201
    @user
    end


    params do###Only for endpoint below
        requires :content
        requires :user_id
    end

    #Create a post for a user
    #AUTHORIZATION WORKS
    post ':id/:api_key/posts' do
    user = params[:id]
    api_key = params[:api_key]
    if authenticate_user user, api_key
      @user = User.find(params[:id])
      @micropost = @user.microposts.create(content: params[:content], 
                                         user_id: params[:user_id])
      #if authenticate_user(@micropost,@user) == true
      status 201
      #@micropost
    else 
       error!('401 Unauthorized', 401) 
    end
  end

  end#end users resource



  resource :microposts do
       # Get all Microposts
    get do
          Micropost.all
    end


    get 'comments' do#Get all of a users microposts
        micropost = Micropost.find(params[:id])
        micropost.comments
    end

      

    namespace do#start namespace scope

    params do
           requires :id, type: Integer
    end
    
    #Get a micropost
    get ':id' do
            Micropost.find(params[:id])
    end
       end#end namespace

   
 
    #Delete a comment - 
    
   

    #Delete all of a Microposts comments
    delete ':id/comments' do
      #AUTHORIZATION
         @post = Micropost.find(params[:id])
         @post.comments.clear
    end

    #Delete a Micropost
    #AUTHORIZATION
    #WORKS
    delete ':id/:api_key' do
    
    post = Micropost.find_by_id(params[:id])##Meant to be number
    user = post.user.id
    api_key = params[:api_key]
    
    if authenticate_user user, api_key

         @post = Micropost.find(params[:id])
         @post.destroy()
       else
        error!('401 Unauthorized', 401) 
      end
    end

    #Delete all Microposts
    #AUTHORIZATION?
    #delete do
    #   Micropost.destroy_all()
    #end 
  end#micropost resource
  
  resource :tags do 
    #Get all tags
    get do
     Tag.all
    end
    
    get ':id' do
     @tag = Tag.find(params[:id])
     @tag
    end

    #Get microposts by their tags
    get ':id/posts' do
    @tag = Tag.find(params[:id])
    @tag.microposts
    end

    #Create a new tag
    post  do
     @tag = Tag.new
     @tag.name = params[:name] if params[:name]
     @tag.save
     status 201
     #curl -d '@b' -X POST  http://localhost:3000/api/tags
     #^ almost works
   #  @tag
    end

    #Tag a micropost
    post ':tag_id/:micropost_id'do
       @tag = Tag.find_by_id(params[:tag_id])
       @micropost = Micropost.find_by_id(params[:micropost_id])
       @micropost.tags << @tag
    end
    
end#end tags resource

resource :comments do

  #Get all comments - 
    get 'api/comments' do
         Comment.all
    end


#Create a comment

    #AUTHORIZATION WORKS
    post ':id/:api_key' do

    user = params[:id]##Meant to be number
    api_key = params[:api_key]
    
    if authenticate_user user, api_key
          @comment = Comment.new
          @comment.content = params[:content] #if params[:content]
          @comment.user_id = params[:user_id] #if params[:user_id]
          @comment.micropost_id = params[:micropost_id] #if params[:micropost_id]
          status 201
          @comment.save
          @comment
        else
       error!('401 Unauthorized', 401) 
    end
    end
 
    #Get a specific comment
    get 'api/comments/:id' do
           Comment.find(params[:id])
    end

    #Delete all comments - 
    delete 'api/comments' do
        Comment.destroy_all()
    end

    #AUTHORIZATION WORKS
    delete 'api/comments/:id/:api_key' do
        @comment = Comment.find(params[:id])
        user = @comment.user.id
        api_key = params[:api_key]
      if authenticate_user user, api_key
        @comment.destroy()
      else
        error!("Unauthorized user!", 401)
      end
    end

end#end comments resource
end#class

class API < Grape::API

  mount Blog::API1
  mount Blog::API2

   end



end#module