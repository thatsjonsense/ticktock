@activeStocks = ->
  symbols = []
  for investor in Investors.find({}).fetch()
    symbols = _.union(symbols, investor.symbolsOwnedEver())
  return (Stocks.findOrInsert({symbol: s}) for s in symbols)



Meteor.startup ->

  # Check for  historical data. If we don't have any, grab it
  for stock in activeStocks()
    if Quotes.find({symbol: stock.symbol}).count() == 0
      debug "Grabbing historical data for #{stock.symbol}"
      GoogleFinance.getQuotesPast(stock,2)


  # Ensure we have a constant stream of quotes
  debug "Generating new data"
  Meteor.setIntervalInstant(->
    for stock in activeStocks()
      if Stock.tradingActive()
        # Live data
        YahooFinance.getQuote(stock)
      else
        # Random data
        RandomWalk.getQuote(stock)

      

  , 1000)