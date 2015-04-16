Router.map ->
	# This template is rendered when the user doesn't specify a path
	this.route "Posts",
		path: ['/', '/posts']
		waitOn: ->
			Meteor.subscribe "posts"
		data: ->
			if this.ready
				posts: posts_collection.find()
