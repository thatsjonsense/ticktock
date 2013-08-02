


Meteor.startup ->

  # Get the list of active stocks
  if Stocks.find().count() == 0

    for symbol in ['GOOG','MSFT','LNKD','CMG']
      Stocks.insert({symbol: symbol})


  active_stocks = Stocks.find().fetch()



  # Ensure we have a constant stream of quotes

  Meteor.setInterval(->
    for stock in active_stocks
      # Live data
      QuoteSourceRandom.getQuote(stock)

      # Random data
  

  , 5000)