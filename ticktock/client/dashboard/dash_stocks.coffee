
Template.dashboard_stocks.stocks = ->
  stocks = Stocks.find({})
 
  # Todo: get a list of all the active stocks we're tracking

Template.dashboard_stocks.quotes = ->
  prettify(Quotes.find({},{limit: 10, sort: {time: -1}}).fetch())
  
Template.stock_row.updown = ->
  if @todayGain() >= 0 then "up" else "down"

Template.stock_row.currentPrice = ->
  t = minutesAgo(Session.get('timeLagMinutes'))
  @priceAt t