Router.map ->
	# This template is rendered when the user doesn't specify a path
	this.route "Main", path: "/" 
	
	# show details about a single post
	this.route "PostDetails", # we can re-use the template because it is still expecting a single post object with the same attributes as when called from the "Main" template
		path: "/post/:_id"
		waitOn: ->
			[ Meteor.subscribe('blog_posts'), Meteor.subscribe('comments') ]
		data: ->
			if this.ready()
				post: blog_posts.findOne(this.params._id)
				comments: comments.find(post_id: this.params._id)
