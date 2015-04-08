# Meteor Tutorial
## Learning Without Training Wheels

There are a lot of meteor tutorials out there, but once you get through them, 
you're left with an application that cna't grow.  It sends too much data around,
it lets anyone access anything, and there is no real organization to expand upon.  

The point of this tutorial is to get you started down the path of writing the basis of a
"real" application the "right way" from the beginning.  

NOTE: This tutorial uses coffeescript, a pseudo-language that is compiled into javascript on the server side before it is sent to the web browser.  I find it to be much more elegant and easier to understand than javascript.  Even if you don't know coffeescript, you should be able to follow the examples well enough to understand what's going on.  More information about coffeescript is here: http://coffeescript.org/

## Install Meteor
Everything you need is right here: http://docs.meteor.com/#/full/quickstart

## Create your project
(The following command automatically makes its own subdirectory, so there's no need for you to do that ahead of time.)
```bash
> meteor create BlogMaker
```
Creates a subdirectory called BlogMaker with a few files to create a small sample app, and the .meteor 
subdirectory which contains all the information about your project that meteor needs to run it.

## Run the sample project
In the BlogMaker directory, simply type:
```bash
> meteor
```
and wait for it to say
> => App running at: http://localhost:3000/

Now, point your web browser at http://localhost:3000/ and you should see a button press counting app.

## Now delete all that crap
We're going to start from scratch without all the crutches in place.
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

The iron:router package allows for handling of requests with different paths set (treating `/foo` and `/bar` differently).  Surprisingly this is not part of the core functionality of Meteor.

