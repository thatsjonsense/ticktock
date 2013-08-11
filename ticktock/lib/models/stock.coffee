# General info about stocks

@Stocks = new Meteor.Collection('stocks',
  transform: (doc) ->
    s = new Stock(doc)
)

if Meteor.isServer
  Stocks._ensureIndex({symbol: 1})
  
class @Stock
  constructor: (doc) ->
     _.extend(@,doc)
     @latest_quote = new Deps.injective(null)

  @lookup: (symbol) -> Stocks.findOne({symbol: symbol})


  # Todo: timezones. guh.
  @tradingDay: (time = do defaultTime) ->
    trading_day = Date.create(time)
    trading_day.setHours(0,0,0,0)
    return trading_day

  @tradingOpen: (time = do defaultTime) ->
    trading_open = Date.create(@tradingDay(time))
    trading_open.setHours(9-3,30,0,0)
    return trading_open

  @tradingClose: (time = do defaultTime) ->
    trading_close = Date.create(@tradingDay(time))
    trading_close.setHours(12+4-3,0,0,0)  
    return trading_close

  @tradingActive: (time = do defaultTime) ->
    time.isBetween(@tradingOpen(time),@tradingClose(time)) and time.isWeekday()