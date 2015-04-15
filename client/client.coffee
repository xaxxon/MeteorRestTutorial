
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
		

timeTick = new Tracker.Dependency()
	
fromNowReactive = (date)->
	timeTick.depend()
	if date? then moment(date).fromNow() else "unknown"
		
Template.PostDetails.helpers
	created_time_description: (date)-> fromNowReactive(date)
	created_timestamp: (date)-> if date? then moment(date).format("dddd, MMMM Do YYYY, h:mm:ss a") else "unknown"
	
	
# At the bottom of the client code
Accounts.ui.config({
  passwordSignupFields: "USERNAME_ONLY"
});
