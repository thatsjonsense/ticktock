
@print = (stuff...) ->
  console.log(stuff...)

@debug = (stuff) ->
	console.log(prettify(stuff))

@prettify = (stuff) ->
	JSON.stringify(stuff,null,2)