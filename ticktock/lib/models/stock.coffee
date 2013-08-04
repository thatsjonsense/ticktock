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
  latestQuote: ->
    if Meteor.isClient
      q = Quotes.findOne
        symbol: @symbol
        time: {$lte: virtualTime()}
      ,
        sort: {time: -1}


  # Ticks

  tickNow: ->
    Ticks.findOne
      symbol: @symbol
    ,
      sort: {time: -1}

  tickAt: (time) ->
    Ticks.findOne
      symbol: @symbol
      time: {$lte: time}
    ,
      sort: {time: -1}

  tickPrevClose: (time) ->
    @tickAt Stock.tradingClose(daysBefore(time,1))

  tickLastClose: ->
    @tickPrevClose now()

  # Prices

  # LIVE, will stay up to date as time ticks
  priceNow: -> 
    @priceAt()

  # NOT LIVE, fixed moment in time
  priceAt: (time) ->
    if time?
      t = @tickAt(time)
    else
      time = now()
      t = @tickNow()
    if t? then parseFloat(t.price) else null

  pricePrevClose: (time) ->
    @priceAt Stock.tradingClose(daysBefore(time,1))

  priceLastClose: ->
    @pricePrevClose now()


  # Stats

  todayGain: ->
    @priceNow() - @priceLastClose()

  dayGain: (time) ->
    @priceAt(time) - @pricePrevClose(time)

  todayGainRelative: ->
    @todayGain() / @priceLastClose()

  dayGainRelative: (time) ->
    @dayGain(time) / @pricePrevClose(time)



# Pubsub
# -------



if Meteor.isServer
  Meteor.publish('Stocks.active', -> Stocks.find({}))

if Meteor.isClient
  Meteor.subscribe('Stocks.active')

  ###
  Remaining issue: when the user changes timeLag, subscription gets rerun. That's fine except it deletes all the old documents. How do I preserve them until the new set comes in?

  Option A: when data comes in from subscription, store it in some other client-side data structure. That way updates don't clobber it

  Option B: don't use deps.autorun?

  Option C: two separate stat sets. One for "live data right now" that's specific to time lag. Another "low resolution" that's used for scrubbing

  ###

  