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


    getPastQuotes = (symbol, start, end, interval) ->
      quotes = []
      stock = Stock.lookup(symbol)
      for lag in [start...end] by interval
        tick = stock.latestTick(secondsAgo(-lag))
        quote = quoteFromTick(tick)
        quote.type = 'past'
        quote._id += 'keep'
        quotes.push(quote)

      return quotes

    Meteor.publish('Stock.pastQuotes',pubArray(getPastQuotes,'quotes'))

    getLatestQuotes = (symbol, delay, before = 10, after = 10) ->

      ticks = Ticks.find
        symbol: symbol
        time:
          $lte: secondsAgo(delay - after)
      ,
        limit: before + after
        sort:
          time: -1
      .fetch()

      quotes = []
      for tick in ticks
        quote = quoteFromTick(tick)
        quote.type = 'latest'
        quotes.push(quote)

      return quotes

    Meteor.publish('Stock.latestQuotes',pubArray(getLatestQuotes,'quotes'))


  # Subscribing
  if Meteor.isClient
    
    Deps.autorun ->
      for stock in Stocks.find().fetch()
      #for stock in Stocks.find({symbol: 'MSFT'}).fetch()
        print 'Subscribing to ' + stock.symbol + ' with delay ' + Session.get('timeLag')
        Meteor.subscribe('Stock.latestQuotes',stock.symbol,Session.get('timeLag'))

    Deps.autorun ->
      if max? and interval?
        for stock in Stocks.find().fetch()
        #for stock in Stocks.find({symbol: 'MSFT'}).fetch()
          print 'Subscribing to ' + stock.symbol + ' for stock.pastQuotes'
          Meteor.subscribe('Stock.pastQuotes',stock.symbol,-max,0,interval)
