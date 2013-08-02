# General info about stocks

@Quotes = new Meteor.Collection('quotes')
@Stocks = new Meteor.Collection('stocks',
  transform: (doc) ->
    s = new Stock(doc)
)

class @Stock
  constructor: (doc) -> _.extend(@,doc)

  @lookup: (symbol) -> Stocks.findOrInsert({symbol: symbol})



  # Decide which trading day a time corresponds to
  # Todo: timezones. guh.
  @tradingDay: (time) ->
    trading_day = time
    trading_day.setHours(0,0,0,0)
    return trading_day

  @tradingOpen: (time) ->
    trading_day = @tradingDay(time)
    trading_day.setHours(9-3,30,0,0)
    return trading_day

  @tradingClose: (time) ->
    trading_day = @tradingDay(time)
    trading_day.setHours(12+4-3,0,0,0)  
    return trading_day



  quotesSince: (time) ->
    Quotes.find
      symbol: @symbol
      time:
        $gte: time


  quoteNow: ->
    Quotes.findOne({symbol: @symbol},{sort: {time: -1}})

  quoteAt: (time) ->
    Quotes.findOne({symbol: @symbol, time: {$lte: time}},{sort: {time: -1}})

  quotePrevClose: (time) ->
    @quoteAt Stock.tradingClose(daysBefore(time,1))

  quoteLastClose: ->
    @quotePrevClose now()


  # LIVE, will stay up to date as time ticks
  priceNow: -> 
    @priceAt()

  # NOT LIVE, fixed moment in time
  priceAt: (time) ->
    if time?
      q = @quoteAt(time)
    else
      time = now()
      q = @quoteNow()
    if q? and q.time >= minutesBefore(time,1000) then parseFloat(q.price) else null

  pricePrevClose: (time) ->
    @priceAt Stock.tradingClose(daysBefore(time,1))

  priceLastClose: (time) ->
    @pricePrevClose now()





