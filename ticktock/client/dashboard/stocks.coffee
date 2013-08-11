
Template.dashboard_stocks.stocks = ->
  Stocks.find().fetch()
  
  # Todo: get a list of all the active stocks we're tracking

Template.dashboard_stocks.quotes = ->
  Quotes.find
    symbol: 'MSFT'
  ,
    sort:
      type: 1
      time: -1
    limit: 100


Template.stock_row.updown = ->
  if @up then "up" else "down"


Template.stock_row.currentPrice = ->
  @price

Template.stock_row.currentGain = -> @gain

Template.stock_row.currentGainRelative = -> @gainRelative