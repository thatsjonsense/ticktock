@Quotes = new Meteor.Collection('quotes')



quoteFromTick = (tick) ->

  stock = Stock.lookup(tick.symbol)
  time = tick.time
  price = tick.price
  last_price = stock.prevCloseTick(time)?.price

  quote =
    _id: tick._id
    symbol: tick.symbol
    time: tick.time
    price: tick.price
    last_price: last_price
    gain: if last_price then (price - last_price) else null
    gainRelative: (price - last_price) / last_price

Meteor.startup ->

  # Publishing
  if Meteor.isServer


    getPastQuotes = (symbol, start, end = 0, max_quotes = 20) -> 
      range = end - start
      interval = Math.ceil(range / max_quotes)

      quotes = []
      stock = Stock.lookup(symbol)
      for lag in [start...end] by interval
        tick = stock.latestTick(secondsAgo(-lag))
        quote = quoteFromTick(tick)
        quote.type = 'past'
        quotes.push(quote)

      return quotes

    Meteor.publish('Stock.pastQuotes',pubArray(getPastQuotes,'quotes'))

    getLatestQuotes = (symbol, delay, before = 5, after = 20) ->

      ###
      ticks = Ticks.find
        symbol: symbol
        time:
          $lte: secondsAgo(delay - after)
      ,
        limit: before + after
        sort:
          time: -1
      .fetch()
      ###

      ticks_after = Ticks.find
        symbol: symbol
        time:
          $gte: secondsAgo(delay)
      ,
        limit: after
        sort:
          time: 1
      .fetch()

      ticks_before = Ticks.find
        symbol: symbol
        time:
          $lt: secondsAgo(delay)
      ,
        limit: before
        sort:
          time: -1
      .fetch()

      ticks = _.union(ticks_after,ticks_before)

      quotes = []
      for tick in ticks
        quote = quoteFromTick(tick)
        quote.type = 'latest'
        quotes.push(quote)

      return quotes

    Meteor.publish('Stock.latestQuotes',pubArray(getLatestQuotes,'quotes'))


  # Subscribing
  if Meteor.isClient
    

    # Wait for timeLag to stabilize

    current_timelag = null
    previous_timelag = null
    stableTimeLag = ->
      previous_timelag = current_timelag
      current_timelag = Session.get('timeLag')
      if previous_timelag == current_timelag
        Session.set('timeLagStable',current_timelag)
    Meteor.setIntervalInstant(stableTimeLag,500)

    Deps.autorun ->
      for stock in Stocks.find().fetch()
      #for stock in Stocks.find({symbol: 'MSFT'}).fetch()
        safeSubscribe('Stock.latestQuotes',stock.symbol,Session.get('timeLagStable'))

    Deps.autorun ->
      for stock in Stocks.find().fetch()
      #for stock in Stocks.find({symbol: 'MSFT'}).fetch()
        safeSubscribe('Stock.pastQuotes',stock.symbol,-max)