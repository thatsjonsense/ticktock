@activeStocks = ->
  symbols = []
  for investor in Investors.find({}).fetch()
    symbols = _.union(symbols, investor.symbolsOwnedEver())
  return (Stocks.findOrInsert({symbol: s}) for s in symbols)





updateQuotes = ->

  for stock in activeStocks()

    # Check for  historical data. If we don't have any, grab it
    if Quotes.find({symbol: stock.symbol, source: 'historical'}).count() == 0
      debug "Grabbing historical data for #{stock.symbol}"
      GoogleFinance.getQuotesPast(stock,2)
    
    # If the market's open, grab live data
    else if Stock.tradingActive()
      YahooFinance.getQuote(stock)
    
    # Otherwise, generate them randomly (for fun)
    else
      RandomWalk.getQuote(stock)



Meteor.startup ->

  Meteor.setIntervalInstant(updateQuotes,1000)