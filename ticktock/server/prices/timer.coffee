@activeStocks = ->
  symbols = []
  for investor in Investors.find({}).fetch()
    symbols = _.union(symbols, investor.symbolsOwnedEver())
  return (Stocks.findOrInsert({symbol: s}) for s in symbols)




###
updateQuotes = ->

  for stock in activeStocks()

    # Check for  historical data. If we don't have any, grab it
    if Quotes.find({symbol: stock.symbol, source: 'historical'}).count() == 0
      debug "Grabbing historical data for #{stock.symbol}"
      GoogleFinance.getQuotesPast(stock,2)
    
    # If the market's open, grab live data
    else if Meteor.settings.quotes == 'live'
      YahooFinance.getQuote(stock)
    
    # Otherwise, generate them randomly (for fun)
    else
      RandomWalk.getQuote(stock)
###


updateQuotes = ->

  for stock in activeStocks()

    # Check if we have fresh data
    if stock.lastUpdated? and stock.lastUpdated > minutesAgo(5)
      # do nothing
    else
      #Get fresh data
      debug "Grabbing historical data for #{stock.symbol}"
      Stocks.update stock._id, {$set: {lastUpdated: now()}}
      GoogleFinance.getQuotesPast(stock,2)


Meteor.startup ->

  Meteor.setInterval(updateQuotes,30*1000)

#todo: better Yahoo rate limiting. Supposed to be <-.2 calls per second.