
Template.dashboard_stocks.stocks = ->
  viewing_user = Investors.findOne Session.get('viewingUserId')
  if viewing_user
    return Stocks.find
      symbol:
        $in: _.keys(viewing_user.symbolsOwnedAt())
    .fetch()

  else
    return Stocks.find().fetch()
    

Template.dashboard_stocks.title = ->
  viewing_user = Investors.findOne Session.get('viewingUserId')
  if viewing_user
    return viewing_user.name + "'s Portfolio"
  else
    return "All Stocks"



Template.stock_row.owners = ->
  _.reject(@owners,(i) -> i._id == Session.get('viewingUserId'))


Template.stock_row.preserve ['a','table','tbody','tr','td']

Template.stock_row.updown = ->
  if @up then "up" else "down"
