# General info about stocks

@Stocks = new Meteor.Collection('stocks',
  transform: (doc) ->
    s = new Stock(doc)
    return s
)

if Meteor.isServer
  Stocks._ensureIndex({symbol: 1})
  
class @Stock
  constructor: (doc) ->
     _.extend(@,doc)

  @lookup: (symbol) -> Stocks.findOne({symbol: symbol})

  @lastTradingDay: (time = do defaultTime) ->

    if time.isWeekday() and time > @tradingOpen(time)
      return @tradingDay(time)
    else
      return @lastTradingDay daysBefore(@tradingClose(time),1)

  @tradingDay: (time = do defaultTime) ->
    return @tradingClose time

  # The assumption here is that UTC = NYC + 4. May not always be true :( Need a real timezone library.
  @tradingOpen: (time = do defaultTime) ->
    trading_open = Date.utc.create(time)
    trading_open.setUTCHours(9  +4,30,0,0)
    return trading_open

  @tradingClose: (time = do defaultTime) ->
    trading_close = Date.utc.create(time)
    trading_close.setUTCHours(16  +4,0,0,0)  
    return trading_close

  @tradingActive: (time = do defaultTime) ->
    time.isBetween(@tradingOpen(time),@tradingClose(time)) and time.isWeekday()

  @tradingDays: (start, end) ->

    days = []
    t = start
    while t < end
      open = @tradingOpen t
      close = @tradingClose t
      days.push([open,close])
      t = daysAfter(t,1)

    return days