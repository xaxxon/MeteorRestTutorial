

blog_posts_subscription = Meteor.subscribe "blog_posts"


Template.Main.helpers
	posts: ->
		if blog_posts_subscription.ready()
			blog_posts.find()

# Available events are documented here: http://docs.meteor.com/#/full/eventmaps
Template.CreatePost.events
	'submit #create_post': (event)-> 
		event.preventDefault()
		
		# You can't insert directly into the database from the client, so call
		#   the Meteor.methods method we created in the server code
		Meteor.call "create_post", $('#post_title').val(), $('#post_body').val()
		

Template.CreateComment.events
	'submit #create_comment': (event)->
		event.preventDefault()
		Meteor.call "create_comment", this.post._id, $('#comment_body').val()
		
		