


class @QuoteSourceRandom

  @SWING: 0.001

  @getQuote = (stock) ->
    last_price = stock.priceNow() ? randomBetween(10,1000)
    delta = randomBetween(-1, 1) * @SWING * last_price
    Quotes.insert
      symbol: stock.symbol
      time: now()
      price: last_price + delta
