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



useRandom = false
useHistorical = true
useLive = false



updateQuotesNoise = ->

  # Check for  historical data, so random quotes are realistic
  if useHistorical
    for stock in activeStocks()
      if Quotes.find({symbol: stock.symbol, source: 'historical'}).count() == 0
        debug "Grabbing historical data for #{stock.symbol}"
        GoogleFinance.getQuotesPast(stock,2)
  
  if useRandom
    RandomWalk.getQuote(stock)

updateQuotesReal = ->
  if useLive
    for stock in activeStocks()
      YahooFinance.getQuote(stock)



Meteor.startup ->

  Meteor.setIntervalInstant(updateQuotesReal,60*1000)

  Meteor.setIntervalInstant(updateQuotesNoise,1*1000)

#todo: better Yahoo rate limiting. Supposed to be <-.2 calls per second.