Meteor.publish "posts", ->
	posts_collection.find()

Meteor.startup ->
	if posts_collection.find().count() == 0
		posts_collection.insert
			title: "Automatically inserted post"
			body: "This post was automatically inserted so you'd have something to look at"
			