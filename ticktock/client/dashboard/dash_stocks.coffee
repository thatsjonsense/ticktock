
Template.dashboard_stocks.stocks = ->
  stocks = Stocks.find({})
 
  # Todo: get a list of all the active stocks we're tracking

Template.dashboard_stocks.stats = ->
  Stats.find({symbol: 'MSFT'},{sort: {time: -1}}, limit: 18)

Template.dashboard_stocks.quotes = ->
  prettify(Quotes.find({},{limit: 10, sort: {time: -1}}).fetch())
  
Template.stock_row.updown = ->
  if @todayGain() >= 0 then "up" else "down"


latestStat = (symbol) ->
  stat = Stats.findOne
    symbol: symbol
    time: {$lte: virtualTime()}
  ,
    sort: {time: -1}


Template.stock_row.currentPrice = ->
  
  #print "calculating price for #{@symbol}"
  #print 'time: ' + virtualTime()
  #stat = latestStat(@symbol)
  #print stat?.price
  #stat?.price
  latestStat(@symbol)?.price

Template.stock_row.currentGain = -> latestStat(@symbol)?.gain

Template.stock_row.currentGainRelative = -> latestStat(@symbol)?.gainRelative