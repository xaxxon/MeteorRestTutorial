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
> meteor remove insecure autopublish 
```
These packages send all database data to the client all the time and allow the client full read/write access to the
server's database.  Obviously your real app can't allow for that, so why even get started like that?

## Add the packages we want
```bash
> meteor add coffeescript iron:router
```
The coffeescript package looks for files ending in `.coffee` and automatically compiles them to javascript before
sending them to the client.  

The iron:router package allows for handling of requests with different paths set (treating `/foo` and `/bar`
differently).  Surprisingly this is not part of the core functionality of Meteor.

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

## Now let's write some HTML

For files that only need to go to the web browser, we will put them in a subdirectory called `client`.  Meteor
understands this directory name and won't load any files under a client directory into the server.  Vice-versa for
subdirectories named `server`.  `client` and `server` subdirectories can be used anywhere in the directory structure to limit access to certain content.

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

Our first template will be responsible for displaying the contents of a single blog post:
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

## Database connections

In Meteor, both the client and the server appear to have connections to the database.  On the server, it works just as you'd expect.  However, on the client, it's *complicated*.  Obviously, you can't send the entire database to the every client - it would take forever and the bandwidth usage would be astronomical.  To manage this, the client must subscribe to certain feeds the server provides.  This will populate the collection on the client side with only the necessary data for the templates to be rendered.  The thing to keep in mind, however, is that getting the data to the client is asynchronous.  After you ask for the data to be sent to the client, you have to make sure it's done before you start using it.  

Since both our client and our server will need access to the collections in our database, the code to access our collections needs to be available to both.  Create a subdirectory called `shared`.  (Shared is not a special name, but any directory that't not "client" or "server" is sent to both, so `shared` ends up being shared.)

```bash
> mkdir shared
```
In a file called `shared/shared.coffee`, add the following line:
```coffeescript
@posts_collection = new Mongo.Collection "posts"
```
This creates a variable called `posts_collection` that allows both the client and server access to the collection named `posts`.  While it is allowed, you should not put spaces in your collection names.  You're reading my tutorial, you'll just have to trust me on this one.  It is a PITA in certain circumstances.

(The @ sign before it is a coffeescript-ism that lets us use the variable in both the web browser and in an interactive server command prompt we'll use later - so don't worry about the `@`, but it's not a typo)

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
Iron Router is how you map URL paths to your templates.  We want `http://localhost:3000/paths` to be the url to show all the Posts. We'll also make `http://localhost:3000/` a synonym for this for convenience.  Create a file called `shared/router.coffee` with the following:

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

`this.route "Posts"` creates a route which will display the Posts template we created earlier.  

`path:` says this route will be used when the URL is / or /posts.  

`waitOn:` allows us to specify what data is needed for this template to be rendered.  In this case, we need to subscribe to the "posts" data feed we just published on the server.

`data:` is where we set up the data to be used in the dynamic portion of our templates.  Remember the `{{#each posts}}` loop in our `Posts` template?  This is where we populate the posts variable.  Once the data is available on the client (remember, we subscribed to the data, but that doens't mean that it's all been received), we get all the results into an array (actually a database cursor for efficiency, but `#each` is smart enough to handle that).

*It's important that the data attribute be a callback function and not the data itself.*

Now, when the template renders, it will have all the data it needs. 

Make sure meteor is running, and point your web browser at http://localhost:3000/posts and you should see the post you manually inserted earlier.

## Creating blog posts from your browser

This is where I stopped.

## Automatically adding timestamps
`> meteor add matb33:collection-hooks`

## Adding comments to a post

## Adding user accounts

### accounts-ui
Nothing wrong with accounts-ui, specifically, but its customization is limited

### Where you can access user information
#### In templates
#### In code
##### Callbacks




# STUFF BELOW HERE WAS REMOVED TO BE PUT BACK IN LATER


We'll also make another template with a form for creating a new blog post.  This one will be completely static:

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


In the same file, add the following:

```coffeescript
Meteor.methods
	create_post: (title, body)->
		posts_collection.insert 
			title: title
			body: body

```
This creates a method the client can call on the server to create a new post.  It takes parameters just like any local function, but all the information is passed back to the server and the server uses its database connection to actually make the change.



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


