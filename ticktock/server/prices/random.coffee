


class @RandomWalk

  @SWING: 0.001

  @getQuote = (stock) ->
    last_price = Quotes.latest(stock.symbol)?.price
    last_price ?= randomBetween(10,1000)
    delta = randomBetween(-1, 1) * @SWING * last_price
    Quotes.insert
      symbol: stock.symbol
      time: now()
      price: last_price + delta
      last_price: last_price
