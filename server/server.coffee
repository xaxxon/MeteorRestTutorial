
Meteor.publish "posts", ->
	posts_collection.find()
	
Meteor.publish "comments", ->
	comments_collection.find()
 

Meteor.methods

	create_post: (title, body)->
		posts_collection.insert 
			title: title
			body: body
		
	create_comment: (post_id, body)->
		comments_collection.insert 
			post_id: post_id
			body: body
	
	