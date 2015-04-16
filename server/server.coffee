Meteor.publish "posts", ->
	posts_collection.find()
