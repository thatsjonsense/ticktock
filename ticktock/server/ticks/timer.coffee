@active_stocks = []


Meteor.startup ->

  # Get the list of active stocks

  symbols = []
  for investor in Investors.find({}).fetch()
    symbols = _.union(symbols, investor.symbolsOwnedEver())

  @active_stocks = (Stocks.findOrInsert({symbol: s}) for s in symbols)


  # Check for  historical data. If we don't have any, grab it

  for stock in active_stocks
    if Ticks.find({symbol: stock.symbol}).count() == 0
      debug "Grabbing historical data for #{stock.symbol}"
      TickSourceGoogle.getTicksPast(stock,2,60*15)

  # Todo: add some logic to decide if we're still in trading day, to get live or random data

  # Ensure we have a constant stream of quotes

  debug "Generating random data"
  Meteor.setIntervalInstant(->
    for stock in active_stocks
      # Live data
      #TickSourceYahoo.getTick(stock)

      # Random data
      TickSourceRandom.getTick(stock)

  , 1000)