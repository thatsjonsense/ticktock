Template.dashv2_canvas.currentUser = ->
  Investors.findOne({name: 'Jon'})

Template.dashv2_pane.currentUser = ->
  Investors.findOne({name: 'Jon'})


Template.dashv2_canvas.preserve ['div']