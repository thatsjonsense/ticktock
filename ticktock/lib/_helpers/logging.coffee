
if Meteor.isServer
  SHOW_DEBUG = Meteor.settings.debug ? false

if Meteor.isClient
  SHOW_DEBUG = false


@print = (stuff...) ->
  console.log(stuff...)

@debug = (stuff...) ->
	if SHOW_DEBUG
    print(now(),stuff...)

@prettify = (stuff) ->
	JSON.stringify(stuff,null,2)