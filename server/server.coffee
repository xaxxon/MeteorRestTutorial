
Meteor.publish "posts", ->
	posts_collection.find()
	
Meteor.publish "comments", ->
	comments_collection.find()

Meteor.publish "user_posts", (user_id = @userId)->
	posts_collection.find(user_id: user_id)
	
Meteor.startup ->
	posts_collection.before.insert (userId, doc)->
	    doc.createdAt = Date.now()
	

 

Meteor.methods

	create_post: (title, body)->
		posts_collection.insert 
			title: title
			body: body
			user_id: @userId
		
	create_comment: (post_id, body)->
		comments_collection.insert 
			post_id: post_id
			body: body
	
	