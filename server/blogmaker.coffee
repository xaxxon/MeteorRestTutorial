
Meteor.publish "blog_posts", ->
	blog_posts.find()
 
 
Meteor.methods
	create_post: (title, body)->
		blog_posts.insert {title: title, body: body}
		
	
	