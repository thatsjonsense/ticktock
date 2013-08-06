
Template.dashboard_stocks.stocks = ->
  stocks = Stocks.find({}).fetch()
  
  Deps.autorun ->
    for stock in stocks
      q = stock.latestQuote()
      stock.latest_quote.set q

  stocks
  
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
  if @latest_quote.get()?.gain >= 0 then "up" else "down"


Template.stock_row.currentPrice = ->
  @latest_quote.get()?.price

Template.stock_row.currentGain = -> @latest_quote.get()?.gain

Template.stock_row.currentGainRelative = -> @latest_quote.get()?.gainRelative