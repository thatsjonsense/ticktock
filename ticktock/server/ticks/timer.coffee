@active_stocks = []


Meteor.startup ->

  # Get the list of active stocks

  symbols = []
  for investor in Investors.find({}).fetch()
    symbols = _.union(symbols, investor.symbolsOwnedEver())

  @active_stocks = (Stocks.findOrInsert({symbol: s}) for s in symbols)

  # Ensure we have a constant stream of quotes

  Meteor.setInterval(->
    for stock in active_stocks
      # Live data
      #TickSourceYahoo.getTick(stock)

      # Random data
      TickSourceRandom.getTick(stock)

  , 1000)