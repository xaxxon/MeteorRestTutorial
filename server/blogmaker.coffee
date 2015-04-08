
Meteor.publish "blog_posts", ->
	blog_posts.find()
	
Meteor.publish "comments", ->
	comments.find()
 

Meteor.methods

	create_post: (title, body)->
		blog_posts.insert 
			title: title
			body: body
		
	create_comment: (post_id, body)->
		comments.insert 
			post_id: post_id
			body: body
	
	