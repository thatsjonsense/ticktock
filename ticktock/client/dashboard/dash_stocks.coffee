
Template.dashboard_stocks.stocks = ->
  stocks = Stocks.find({})
 
  # Todo: get a list of all the active stocks we're tracking

Template.dashboard_stocks.quotes = ->
  Quotes.find({symbol: 'MSFT'},{sort: {time: -1}}, limit: 18)

  
Template.stock_row.updown = ->
  if @latestQuote()?.gain >= 0 then "up" else "down"


Template.stock_row.currentPrice = ->
  
  #print "calculating price for #{@symbol}"
  #print 'time: ' + virtualTime()
  #stat = latestStat(@symbol)
  #print stat?.price
  #stat?.price
  @latestQuote()?.price

Template.stock_row.currentGain = -> @latestQuote()?.gain

Template.stock_row.currentGainRelative = -> @latestQuote()?.gainRelative