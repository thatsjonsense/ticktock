


class @TickSourceRandom

  @SWING: 0.001

  @getTick = (stock) ->
    last_price = stock.latestTick()?.price
    last_price ?= randomBetween(10,1000)
    delta = randomBetween(-1, 1) * @SWING * last_price
    Ticks.insert
      symbol: stock.symbol
      time: now()
      price: last_price + delta
