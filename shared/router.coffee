Router.map ->
	# This template is rendered when the user doesn't specify a path
	this.route "Posts",
		path: ['/', '/posts']
		waitOn: ->
			Meteor.subscribe "posts"
		data: ->
			if this.ready()
				posts: posts_collection.find()
			
	
	# show details about a single post
	this.route "PostDetails", # we can re-use the template because it is still expecting a single post object with the same attributes as when called from the "Main" template
		path: "/posts/:_id"
		waitOn: ->
			[ Meteor.subscribe('posts'), Meteor.subscribe('comments') ]
		data: ->
			if this.ready()
				post: posts_collection.findOne(this.params._id)
				comments: comments_collection.find(post_id: this.params._id)
