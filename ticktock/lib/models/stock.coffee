# General info about stocks

@Quotes = new Meteor.Collection('quotes')

@Stats = new Meteor.Collection('stats')

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


  # Quotes

  quotesSince: (time) ->
    Quotes.find
      symbol: @symbol
      time:
        $gte: time


  quotesAfter: (time,limit) ->
    "Return the next LIMIT quotes after TIME"
    Quotes.find(
      symbol: @symbol
      time:
        $gte: time
    ,
      limit: limit
    )

  quoteNow: ->
    Quotes.findOne({symbol: @symbol},{sort: {time: -1}})

  quoteAt: (time) ->
    Quotes.findOne({symbol: @symbol, time: {$lte: time}},{sort: {time: -1}})

  quotePrevClose: (time) ->
    @quoteAt Stock.tradingClose(daysBefore(time,1))

  quoteLastClose: ->
    @quotePrevClose now()

  # Prices

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
    if q? then parseFloat(q.price) else null

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


  NUM_BEFORE = 10
  NUM_AFTER = 10
  INTERVAL = 1 # time between user-facing ticks
  SERVER_INTERVAL = 1 # how often we send new info to client

  pubStockStats = (symbol,delay) ->

    # If the user resubscribes, kill the last timer
    
    

    @onStop ->
      if @timer then Meteor.clearInterval(@timer)

    # The set of documents we're sending the user. Keys are IDs
    @buffer = {}

    @timer = Meteor.setInterval(=>

      query = Quotes.find
        symbol: symbol
        time: {$lte: secondsAgo(delay - (NUM_AFTER * INTERVAL))}
      ,
        limit: NUM_BEFORE + NUM_AFTER
        sort: {time: -1}
      
      quotes = query.fetch()

      # Find items in @buffer that aren't in @quotes, and remove them
      # Find items in @quotes that aren't in @buffer, and add them

      for id, doc of @buffer

        if not _.findWhere(quotes, {_id: id})
          #print "Removing #{id} because it wasn't in quotes"
          delete @buffer[id]
          @removed('stats',id)

      for quote in quotes
        id = quote._id
        if @buffer[id]?
          #print "Doing nothing with #{id} because it was in both lists"
        else
          #print "Adding #{id} because it wasn't in buffer"

          stock = Stock.lookup(quote.symbol)
          
          time = quote.time
          price = quote.price
          last_price = stock.pricePrevClose(time)

          stat =
            symbol: quote.symbol
            time: quote.time
            price: quote.price
            last_price: last_price
            gain: if last_price then (price - last_price) else null
            gainRelative: (price - last_price) / last_price
          
          @buffer[id] = stat
          @added('stats',id,stat)

    ,SERVER_INTERVAL * 1000)

  Meteor.publish('Stock.stats', pubStockStats)


if Meteor.isClient

  ###
  Remaining issue: when the user changes timeLag, subscription gets rerun. That's fine except it deletes all the old documents. How do I preserve them until the new set comes in?

  Option A: when data comes in from subscription, store it in some other client-side data structure. That way updates don't clobber it

  Option B: don't use deps.autorun?

  ###

  onStocksReady = ->
    Deps.autorun ->
      for stock in Stocks.find().fetch()
      #for stock in [Stock.lookup('MSFT')]
        print 'Subscribing to ' + stock.symbol + ' with delay ' + Session.get('timeLag')
        Meteor.subscribe('Stock.stats',stock.symbol,Session.get('timeLag'))

  Meteor.subscribe('Stocks.active',onStocksReady)