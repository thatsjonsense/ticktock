



Template.lines.rendered = ->


  red = "#db4437"
  green = "#0f9d58"

  Deps.autorun =>

    current_user = Investors.findOne({name: 'Jon'})

    if current_user?.up
     $('body').css('background-color',green)
    else if current_user?.down
      $('body').css('background-color',red)
    else
      # do nothing