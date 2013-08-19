Template.infographic.currentUser = ->
  Investors.findOne({name: 'Jon'})

Template.infographic.preserve ['div']



red = "#db4437"
green = "#0f9d58"


Template.infographic.rendered = ->
  if @find('.up')
    $('body').css('background-color',green)
  else
    $('body').css('background-color',red)