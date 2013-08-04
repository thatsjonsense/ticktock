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
      TickSourceGoogle.getTicksPast(stock,2)

  # Todo: add some logic to decide if we're still in trading day, to get live or random data

  # Ensure we have a constant stream of quotes

  Meteor.setInterval(->
    for stock in active_stocks
      # Live data
      #TickSourceYahoo.getTick(stock)

      # Random data
      TickSourceRandom.getTick(stock)

  , 1000)