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
  INTERVAL = 1 # between user-facing updates

  pubStockStats = (symbol,delay) ->

    # If the user resubscribes, kill the last timer
    
    

    @onStop ->
      if @timer then Meteor.clearInterval(@timer)
      if @observer then @observer.stop()



    @timer = Meteor.setInterval(=>

      if symbol == 'MSFT'
        print ""
        print('Currently',now())
        print('Client asked for',secondsAgo(delay))
        print('So get documents up to',secondsAgo(delay-NUM_AFTER*INTERVAL))


      query = Quotes.find
        symbol: symbol
        time: {$lte: secondsAgo(delay - (NUM_AFTER * INTERVAL))}
      ,
        limit: NUM_BEFORE + NUM_AFTER
        sort: {time: -1}

      # Kill the last query we ran
      if @observer then @observer.stop()

      #But what do we do about the documents it published?


      @observer = query.observeChanges

        added: (id,quote) =>
          
          if symbol == 'MSFT'
            print('Adding',id)
          

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
          
          @added('stats',id,stat)

        removed: (id,fields) =>
          if symbol == 'MSFT'
            print('Removing',id,fields.symbol)
          @removed('stats',id)

    ,5000)


  Meteor.publish('Stock.stats', pubStockStats)


if Meteor.isClient


  onStocksReady = ->
    Deps.autorun ->
      Stocks.find().forEach (stock) ->
        print 'Subscribing to ' + stock.symbol + ' with delay ' + Session.get('timeLag')
        Meteor.subscribe('Stock.stats',stock.symbol,Session.get('timeLag'))

  Meteor.subscribe('Stocks.active',onStocksReady)

  




###


if Meteor.isServer
  
  

  quotesFrom = (symbol, timeLag) ->
    stock = Stock.lookup(symbol)
    q = stock.quotesAfter(secondsAgo(timeLag),15)

    q.observeChanges ->
      added: (id) ->
        console.log('Adding',id)
        @added('quotes',id)



    #@added('quotes','jdsklfksl',{test: 5})

  Meteor.publish('latest-quotes', quotesFrom) 



if Meteor.isClient

  syncQuotes = ->
    Deps.autorun ->
      for stock in Stocks.find().fetch()
          console.log('subscribing',stock.symbol)
          Meteor.subscribe('latest-quotes',stock.symbol,Session.get('timeLag'))




  Meteor.subscribe('all-stocks', syncQuotes)
###