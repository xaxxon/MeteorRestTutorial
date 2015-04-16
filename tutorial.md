# Meteor Tutorial
## Learning Without Training Wheels

There are a lot of meteor tutorials out there, but once you get through them, 
you're left with an application that can't grow.  It sends too much data around,
it lets anyone access anything, and there is no real organization to expand upon.  

The point of this tutorial is to get you started down the path of writing the basis of a
"real" application the "right way" from the beginning.  

NOTE: This tutorial uses coffeescript, a language that is compiled into javascript on the server side before it is sent to the web browser.  I find it to be much more elegant and easier to understand than javascript.  Even if you don't know coffeescript or don't care for it, you should be able to follow the examples well enough to understand what's going on.  More information about coffeescript is here: http://coffeescript.org/

## Install Meteor
Everything you need to install meteor is right here: http://docs.meteor.com/#/full/quickstart

While meteor is supported on Windows, the instructions below are intended for UNIX/OS X.  You will have to
make changes to any command-line commands for windows to perform the equivalent action.  

## Create your project
(The following command automatically makes its own subdirectory, so there's no need for you to do that ahead of time.)
```bash
> meteor create BlogMaker
```
Creates a subdirectory called BlogMaker with a few files to create a small sample app, and the .meteor 
subdirectory which contains all the information about your project that meteor needs to run it.

## Run the sample project
In the BlogMaker directory, start the webserver by typing:
```bash
> meteor
```
and wait for it to say
> => App running at: http://localhost:3000/

Now, point your web browser at http://localhost:3000/ and you should see a button press counting app.  Press the button to your heart's content.

## Now delete the sample app
We're going to start from scratch
```bash
> rm BlogMaker.js BlogMaker.css BlogMaker.html
```

## Remove the crutch packages
```bash
> meteor remove insecure autopublish jquery
```
These packages send all database data to the client all the time and allow the client full read/write access to the
server's database.  Obviously your real app can't allow for that, so why even get started like that?  Also, jquery package isn't needed for using jquery, either.


## Let's build a blogging system
Seems like every tutorial builds a blog these days, but it has clearly defined objects and interactions which makes it good for showing how the different parts of Meteor work together.

## Quick intro to MongoDB
Meteor uses Mongo as its database.  Mongo is a No-SQL database and its data are not defined by a schema the way SQL data are.  Instead, it stores unstructured documents which are essentially a collection of key/value pairs.  Mongo allows you to group related documents into a collection.  The documents in a collection don't have to have the same keys, though they frequently do.

If you're familiar with SQL, for the purpose of this tutorial it's reasonable to think of collections as tables (though without a schema) and documents as rows in those tables.  

## Defining a blog post
Let's start simple and say a blog post has only two attributes: a title and a body.  Those will be our document key names, and we'll put them in a collection named `posts`.  

Since Mongo documents are unstructured, it will be quite easy for us to add more fields (like the author and a timestsamp) onto a blog post later, as it doesn't involve editing any schemas. 

## Adding a blog post to the database by hand.
Before we write any code, let's pre-populate the database with a blog post or two by hand so when our code is done, we have something to display.

First, make sure meteor is running:
```bash
> meteor
```
and leaving that up in a terminal window.   Then, in another window: 

`> meteor mongo` 

and at the prompt, type in:

`meteor:PRIMARY> db.posts.insert({title: "My first post", body: "Meteor is super fun to program in!"})`

and you should see:

`WriteResult({ "nInserted" : 1 })`

feel free to add as many as you want.  

`meteor:PRIMARY> db.posts.find().count()` to see how many you've added

`meteor:PRIMARY> db.posts.remove({})` if you mess up and want to clear all the documents from a collection


Make sure meteor is running, and point your web browser at http://localhost:3000/posts and you should see the post you manually inserted earlier.


## Accessing the database from code

In Meteor, both the client and the server appear to have the database locally.  On the server, it works just as you'd expect - you actually do have full access to the authoritative database.  On the client, however, it's *complicated*.  Obviously, you can't send the entire database to the every client - it would take forever and the bandwidth usage would be astronomical.  To manage this, the client must subscribe to certain feeds the server provides in order to intelligently populate the local database cache.  This will provide the collection on the client side with only the necessary data for the templates to be rendered.  The thing to keep in mind, however, is that getting the data to the client is asynchronous.  After you ask for the data to be sent to the client, you have to make sure it's done before you start using it.  

Since both our client and our server will need access to the collections in our database, the code to access our collections needs to be available to both.  We will put this code in a directory named `shared`.  (`shared` is not a special name, but any directory that's not named "client" or "server" is sent to both, so `shared` ends up being shared.)

```bash
> mkdir shared
```
In a file called `shared/shared.coffee`, add the following line:
```coffeescript
@posts_collection = new Mongo.Collection "posts"
```
This creates a variable called `posts_collection` that allows both the client and server access to the collection named `posts`.  While it is allowed, you should not put spaces in your collection names.  You're reading my tutorial, you'll just have to trust me on this one.  It is a PITA in certain circumstances.

(The @ sign before it is a coffeescript-ism that lets us use the variable in both the web browser and in an interactive server command prompt we'll use later - so don't worry about the `@`, but it's not a typo)

## Server-side code

```bash
> meteor add coffeescript
```
The coffeescript package looks for files ending in `.coffee` and automatically compiles them to javascript before
sending them to the client.  


Now, in the server, let's use our newly created `posts_collection` variable:

Create a `server` subdirectory
```bash
> mkdir server
```

Create a file `server/server.coffee`  and add the following:

```coffeescript
Meteor.publish "posts", ->
	posts_collection.find()
```

This creates a named data feed that clients can subscribe to.  As we get started, when a client subscribes posts, we will send all of the posts to them.  Later we may choose to limit the results to some number or filter by author, but for now, we'll send everything.  


## Create client code to show the posts

### Iron Router

```bash
> meteor add iron:router
```

Iron Router is how you map URL paths to your templates.  We want `http://localhost:3000/posts` to be the url to show all the Posts. We'll also make `http://localhost:3000/` a synonym to `/posts` for convenience.  Create a file called `shared/router.coffee` with the following:

```coffeescript
Router.map ->
	# This template is rendered when the user doesn't specify a path
	this.route "Posts",
		path: ['/', '/posts']
		waitOn: ->
			Meteor.subscribe "posts"
		data: ->
			if this.ready()
				posts: posts_collection.find()
```

This looks a little complicated, but it's not too bad.

`Router.map ->` just gets us started.  As you add more routes, you'll just add to the section below it.

`this.route "Posts"` creates a route which will display the HTML template we will create next.  

`path:` says this route will be used when the URL is / or /posts.  

`waitOn:` allows us to specify what data is needed for this template to be rendered.  In this case, we need to subscribe to the "posts" data feed we just published on the server.

`data:` is where we set up the data to be used in the dynamic portion of our templates.  Our HTML we write next will expect an array of our blog posts named `posts`.  This is where we put the data into it.  Technically `posts` is a database cursor which can be used to get the posts.

*It's important that the data attribute be a callback function and not the data itself.*

Now, when the template renders, it will have all the data it needs. 


## Now let's write some HTML

For files that only need to go to the web browser, we will put them in a subdirectory called `client`. 

```bash
> mkdir -p client/html
```

Now create a file called `client/BlogMaker.html`.  Filenames in Meteor aren't important in general, but the extensions often are.

We start out just like a normal HTML file...

```HTML
<head>
	<title>
		BlogMaker
	</title>
</head>
<body>
  <!-- This will be filled in by the template selected by iron:router -->
</body>
```
...but we leave the body empty.  This will get filled in depending on what page we want to display.  

Next, we will create our first Meteor template.  A template is the primary unit of content in Meteor.  Most
everything you do in Meteor will revolve around templates.  Creating a template looks just like any other HTML element and has one critical attribute: it's name.  In your code as well as your HTML you will refer to the template by this case-sensitive name.

Our first template will be responsible for displaying the contents of a single blog post.  Add the following to the bottom of `client/html/blogmaker.html`
```HTML
<!-- Shows a single blog posting, the title, and body -->
<template name='Post'>
	<div class='post_title'>{{title}}</div>
	<div class='post_body'>{{body}}</div>
</template>
```
As you can see, it's mostly normal HTML, but the curly braces are bound to look a little strange.  That's where the dynamic portions of the template are.

Templates in Meteor use a system called Spacebars
(https://github.com/meteor/meteor/blob/devel/packages/spacebars/README.md) for inserting dynamic content into HTML.
You can recognize Spacebars code by the double curly braces which begin and end each section.

In this case, the section inside the Spacebars blocks are simply replaced with the value of the variable when the
template is rendered.  Having the names in the template match the attribute names in the document we added to the database earlier makes things easier, but isn't required.

Our template only shows one blog posting, though.  We want a page that shows them all.  Create another template in the same file:

```HTML
<template name='Posts'>
    {{#each posts}}
        {{>Post}}
    {{/each}}
</template>
```

In this case, our template expects us to provide it with an array of posts in the `posts` variable.  Meteor will iterate over and each element of the array and render an instance of the `Post` template we previously created.

`{{>TemplateName}}` is the Spacebars instruction to render the template called `TemplateName`

## Run your code and see your blog post

`> meteor`

and point your browser at http://localhost:3000

## Check out and view code at this point

To view code already written up to this point, first, clone this repository, then checkout the tag `Section1`

If you don't have git installed, either follow the directions in your OS, or go here:

http://git-scm.com/downloads

```bash
> git clone https://github.com/xaxxon/MeteorRestTutorial.git

> git checkout section_1
```

There's a little bit of extra code in `server/server.coffee` to make sure there is a blog post for you to look at in case your database was empty.

## Creating blog posts from your browser

### Add the HTML

Time to add the ability to create a new post frmo your browser.

First, create a template in the same `client/html/BlogMaker.html` file as before for displaying the HTML form.  This template will be entirely static HTML.  You could put the HTML directly into the Posts template, but it's good to always be thinking about creating modular, re-useable templates.

```HTML
<!-- Form for creating a new blog post -->
<template name='CreatePost'>
	<form id='create_post'>
		<input type='text' id='post_title'>
		<textarea id='post_body'></textarea>
		<input type='submit'>
	</form>
</template>
```

### Controlling client write access to the database
Allowing a client to directly create and delete documents from our database would be dangerous.  A malicious user could delete someone else's posts.  Because of this, the client has no access to change the database.  Instead, we will introduce a set of explicit methods for the server to allow the client to call.  Eventually, these will contain the logic to make sure the client is allowed to make the change.

in `server/server.coffee`, add the following:

```coffeescript
Meteor.methods
	create_post: (title, body)->
		posts_collection.insert 
			title: title
			body: body

```
This creates a method the client can call on the server to create a new post.  It takes parameters just like any local function would, but all the information is passed back to the server and the server uses its database connection to actually make the change.

Now the client needs to actually call our newly made method when the user submits the HTML form.  In `client/client.coffee` add:

Template.CreatePost.events
	'submit #create_post': (event)-> 
		event.preventDefault()
		
		# You can't insert directly into the database from the client, so call
		#   the Meteor.methods method we created in the server code
		Meteor.call "create_post", $('#post_title').val(), $('#post_body').val()


This is an event handler.  Because it's tied to the CreateComment template, it will only handle events generated from that template.  The list of available events is here: http://docs.meteor.com/#/full/eventmaps

In this handler, we call the method we just created in the server: `create_comment` and pass it the two parameters it expects, the post title and post body.  

Note: We're using jQuery here (http://api.jquery.com/) to get the form values.   That's what the `$` refers to in the code above.  jQuery is available without requesting it be installed like we had to do for coffeescript and iron:router.  

Go ahead and load up the page again and add a blog post to try out your new form.

The super cool thing here is that when you submit the form, you don't have to do anything to make it show up in your browser - you don't even have to reload the page.  This is called reactive programming.  You write the view once and meteor takes care of updating it when the data changes.



## Automatically adding timestamps
One of the important things to associate with your blog posts is when they were created.  Since MongoDB doesn't have an explicit schema, there's no need to change anything in the database, we'll just start adding our documents with a new field, and make sure to handle older-style documents without the field.

We don't want to trust the client to tell us when the blog post was added - it's error prone and able to be set to anything by a 'creative' user.  Instead, let's add some server-side code to add a timestamp whenever a document is created.  

To do that, add the collection hooks package:

`> meteor add matb33:collection-hooks`

and add the following to `server/server.coffee`

```coffeescript
posts_collection.before.insert (userId, doc)->
    doc.createdAt = Date.now()
```

It does exactly what it says - before an insert, it adds the attribute `createdAt` to the document and sets the value to the current date (which includes the time).

Now, let's update the template.

A great package for handling dates is called moment.js.  http://momentjs.com/

`> meteor add momentjs:moment`

Restart meteor and in another terminal pull up 

`> meteor shell` 

and insert a document:

`> posts_collection.insert({"title": "test", "body": "test"})`

note the ID returned (for this example we'll assume it's "Abc123"), and now select it:

`> posts_collection.findOne("Abc123")`

and you'll see it has a `createdAt` field even though you didn't add it.  You can see how moment.js works (make sure you installed it) by typing in:

> moment(posts_collection.findOne("Abc123").createdAt).fromNow()

And you should see something like:

`'a minute ago'`

depending on how long ago you actually inserted the record.  Moment.js accepts a wide variety of date formats, but the javascript Date.now() method we used in our server code happens to be the default format moment.js wants.

Since we don't want to show the raw number (milliseconds since January 1, 1970), we'll need a helper to format it to a string that we want.

```coffeescript
Template.PostDetails.helpers
	created_time_phrase: (time)-> if time then moment(time).fromNow() else "unknown"
```

and then call it from within our template:

```HTML
<div class='created_at'>{{created_time_phrase post.createdAt}}</div>
```

This is how you pass a parameter to a template.  

If you think your helper may be useful from your entire project, you can make it global by using `Template.registerHelper(name, function)` as documented here; http://docs.meteor.com/#/full/template_registerhelper

You'll notice this doesn't make the time "reactive".  After the page is loaded, it doesn't change from "1 minute ago" to "2 minutes ago" a minute later.  This is because none of the Meteor data is changing, only the current time is changing.  

In order to tell Meteor we want to update this, we need to create our own reactive data source.  Since the time is constantly changing and we don't want to overload the browser with work, we will tell it to just recheck once a second.  

The Tracker package (http://docs.meteor.com/#/full/tracker) is how Meteor internally tracks and manages reactive data sources, but exposes it for us to use, as well.  First, you create a new Tracker object

```coffeescript
timeTick = new Tracker.Dependency()
```

Then, once a second (1000 milliseconds), we tell Meteor the data has changed.  

```coffeescript
Meteor.setInterval(
  ->
  	timeTick.changed()
  1000)
```

There's no need to use Meteor's setInterval method (http://docs.meteor.com/#/full/timers) instead of the plain javascript one, but it's a good habit to be in, as it makes sure your environment is what you would want it to be when doing more complicated things.

Now, we just write a helper that, somewhere in its body, says it depends on timeTick.

```coffeescript
Template.PostDetails.helpers
	created_time_phrase: (date)-> (date)->
	timeTick.depend()
	if date? then moment(date).fromNow() else "unknown"
```

Now, your page will begin to automatically update the created time phrase every second, though the return value will only change once a minute since the moment.js `timeFrom()` method only uses minutes in its returned string.

## Adding user accounts

Now let's add user accounts.  There are many ways to authenticate an account, but we will stick to simple passwords.  Also, we are going to cheat a little bit here by using some built-in UI elements for allowing users to log-in and log-out.  We'll go over what you need to make your own afterwards, but it's tedious. 

`> meteor add accounts-password accounts-ui`

This will add both the base account packages as well as the UI packages.

Now in the body segment, add

```HTML
<body>
{{> loginButtons}}
</body>
```

While all the functionality behind this UI can be implemented yourself, it's tedious work.   Everything is documented (http://docs.meteor.com/#/full/accounts_api) and for password authentication, you'll want to look at `Accounts.createUser` and `Accounts.onCreateUser` for creating new accounts (client- and server-side calls respectively), and `Meteor.loginWithPassword` and `Meteor.onLogin` for loging in existing users.  The `Account` methos are well named and organized, so it's easy to find what you want and how to use them.

For simplicity's sake, let's add some code to allow simple usernames instead of requiring a valid email address.  At the bottom of `client/client.coffee`, add:

Accounts.ui.config({
  passwordSignupFields: "USERNAME_ONLY"
});



Go ahead and create an account - click "sign in" then "create account".  Enter a username and a password with confirmation and hit "Create Account".  There are much more powerful things you can do with account creation, but for now the goal is to learn how to use account information in your app, not focus on the actual account creation process.

Account information is automatically available pretty much everywhere you'd want it to be.  When it's provided to you on the server, you don't have to worry about whether you can trust it.  

In Meteor.methods, `this` is set to an object which includes `this.userId`, the alphanumeric database ID representing the user making the call.  It's `null` if the user isn't logged in.

Let's use this to store the user when creating a blog entry by adding a single line to our Meteor.methods in `server/server.coffee`

```coffeescript
	create_post: (title, body)->
		posts_collection.insert 
			title: title
			body: body
			user_id: @userId # This is all we added
```

In a template, you can always refer to the current user with `{{ currentUser }}`.  This means you can check to see if there is a user logged in and display the username easily:

```HTML
{{ #if currentUser }}
  {{ currentUser.username }}
{{ /if }}
```

User information is also available inside publish methods.  To publish only a single user's posts (defaulting to our own), we can now add to `server/server.coffee`

```coffeescript
Meteor.publish "user_posts", (user_id = @userId)->
	polls.find(user_id: user_id) 
```



## Adding comments to a post




### accounts-ui
Nothing wrong with accounts-ui, specifically, but its customization is limited

### Where you can access user information
#### In templates
#### In code
##### Callbacks




# STUFF BELOW HERE WAS REMOVED TO BE PUT BACK IN LATER


We'll also make another template with a form for creating a new blog post.  This one will be completely static:


In the same file, add the following:


## meteor.shell
Meteor's shell command is really cool.  It gives you an interactive javascript prompt into your *running* server process.  This means you have access to everything your server code has access to, but you can poke around in real time.

Right now, we need some blog posts so our client can actually render stuff for us.  In another terminal (remember, meteor still has to be running), run the following:

```bash
> meteor shell
```

Note: if you get the error: `Server unavailable (waiting to reconnect)` that means you're not running meteor (the server) right now.  Go to another terminal and type:

```bash
> meteor
```

and try running `meteor shell` again.

Now, let's look around in the database a little:

```javascript
posts_collection.find().count()
```
should return 0 - because you haven't created any posts yet.  `find()` without any parameters returns every document in the collection.  

```javascript
posts_collection.insert({title: 'test title', body: 'test body'})
```
It should print an alpha-numeric string.  That's the ID of the newly created document.  Every document has a unique ID that can be used to easily and quickly refer to it.  

Create a few more if you want, but when you're done, pull up your web browser and let's try it out: http://localhost:3000/posts

```javascript
posts_collection.find().count()
```
Should now return 1 (or more if you added more)

If you want to clear out all your posts, pass the empty object into the `remove()` method on the collection
```javascript
posts_collection.remove({})
```


```coffeescript
Template.CreateComment.events
	'submit #create_comment': (event)->
		event.preventDefault()
		Meteor.call "create_comment", this.post._id, $('#comment_body').val()
```


 Meteor
understands this directory name and won't load any files under a client directory into the server.  Vice-versa for
subdirectories named `server`.  `client` and `server` subdirectories can be used anywhere in the directory structure to limit access to certain content.



## Resources

https://www.meteor.com/
http://docs.meteor.com/#/full/



