
SHOW_DEBUG = true


@print = (stuff...) ->
  console.log(stuff...)

@debug = (stuff...) ->
	if SHOW_DEBUG
    print(now(),stuff...)

@prettify = (stuff) ->
	JSON.stringify(stuff,null,2)