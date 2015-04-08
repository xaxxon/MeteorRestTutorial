
Meteor.publish "blog_posts", ->
	console.log blog_posts.find().count()
	blog_posts.find()
 
 
Meteor.methods
	create_post: (title, body)->
		blog_posts.insert {title: title, body: body}
		
	
	