Router.map ->
	# This template is rendered when the user doesn't specify a path
	this.route "Main", path: "/" 

	# show details about a single post
	this.route "Post", # we can re-use the template because it is still expecting a single post object with the same attributes as when called from the "Main" template
		path: "/post/:_id"
		waitOn: ->
			Meteor.subscribe 'blog_posts'
		data: ->
			if this.ready()
				blog_posts.findOne(this.params._id)
