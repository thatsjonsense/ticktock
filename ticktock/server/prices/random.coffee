


class @RandomWalk

  @SWING: 0.001

  @getQuote = (stock) ->
    most_recent_price = Quotes.latest(stock.symbol)?.price
    last_price = Quotes.latest(stock.symbol)?.last_price

    most_recent_price ?= randomBetween(10,1000)
    delta = randomBetween(-1, 1) * @SWING * most_recent_price

    Quotes.insert
      symbol: stock.symbol
      time: now()
      price: most_recent_price + delta
      last_price: last_price
      
