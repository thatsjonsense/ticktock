# General info about stocks

@Stocks = new Meteor.Collection('stocks',
  transform: (doc) ->
    s = new Stock(doc)
)

@Ticks = new Meteor.Collection('ticks')

if Meteor.isServer
  Stocks._ensureIndex({symbol: 1})
  Ticks._ensureIndex({symbol: 1, time: -1})

class @Stock
  constructor: (doc) ->
     _.extend(@,doc)
     @latest_quote = new Deps.injective(null)

  @lookup: (symbol) -> Stocks.findOne({symbol: symbol})



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


  # Quotes
  latestQuote: (time = do defaultTime) ->
    if Meteor.isClient

      q = Quotes.findOne
        symbol: @symbol
        time: {$lte: time}
      ,
        sort: {time: -1}

  # Ticks
  latestTick: (time = do defaultTime) ->
    if Meteor.isServer

      t = Ticks.findOne
        symbol: @symbol
        time: {$lte: time}
      ,
        sort: {time: -1}

  prevCloseTick: (time = do defaultTime) ->
    yesterday = daysBefore(time,1)
    close_time = Stock.tradingClose(yesterday)
    @latestTick(close_time)


if Meteor.isServer
  Meteor.publish('Stocks.active', -> Stocks.find({}))

if Meteor.isClient
  Meteor.subscribe('Stocks.active')

  