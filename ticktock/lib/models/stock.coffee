# General info about stocks

@Stocks = new Meteor.Collection('stocks',
  transform: (doc) ->
    s = new Stock(doc)
)

@Ticks = new Meteor.Collection('ticks')

class @Stock
  constructor: (doc) -> _.extend(@,doc)

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
  latestQuote: (time) ->
    if Meteor.isClient
      time ?= virtualTime()

      q = Quotes.findOne
        symbol: @symbol
        time: {$lte: time}
      ,
        sort: {time: -1}

  # Ticks
  latestTick: (time) ->
    if Meteor.isServer
      time ?= now()

      t = Ticks.findOne
        symbol: @symbol
        time: {$lte: time}
      ,
        sort: {time: -1}

  prevCloseTick: (time) ->
    yesterday = if time? then daysBefore(time,1) else daysAgo(1)
    close_time = Stock.tradingClose(yesterday)
    @latestTick(close_time)


if Meteor.isServer
  Meteor.publish('Stocks.active', -> Stocks.find({}))

if Meteor.isClient
  Meteor.subscribe('Stocks.active')

  