

Template.dashboard_investors.investors = ->
  investors = Investors.find().fetch()

Template.investor_row.updown = -> if @up then "up" else "down"