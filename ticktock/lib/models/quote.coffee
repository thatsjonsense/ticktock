@Quotes = new Meteor.Collection('quotes')

if Meteor.isServer
  Quotes._ensureIndex {time: -1}


Quotes.latest = (symbol, time = do defaultTime, n=1) ->
  if n == 1
    q = Quotes.findOne
      symbol: symbol
      time: {$lte: time}
    ,
      sort: {time: -1}
      limit: n
  else
    q = Quotes.find
      symbol: symbol
      time: {$lte: time}
    ,
      sort: {time: -1}
      limit: n
    .fetch()


Meteor.startup ->

  if Meteor.isServer

    updatePrices = (delay) ->
      time = secondsAgo(delay)

      # Initial setup
      @investors_observer ?= Investors.find().observeChanges
        added: (id,fields) =>
          #debug "Added investor #{fields.name}"
          @added('investors',id,fields)
        changed: (id,fields) =>
          #debug "Changed investor #{id} to #{fields}"
          @changed('investors',id,fields)

      @stocks_observer ?= Stocks.find().observeChanges
        added: (id, fields) =>
          #debug "Added stock #{fields.symbol}"
          @added('stocks',id,fields)

      investors = Investors.find().fetch()
      stocks = Stocks.find().fetch()

      # Update stock prices and values
      for i in investors
        i.value = 0
        i.last_value = 0

        for symbol, shares of i.symbolsOwnedAt(time)
          #print "#{i.name} owns #{symbol}"
          s = _.findWhere stocks, {symbol: symbol}

          # If stock can't be found, might be getting added now
          if s
            q = Quotes.latest(symbol, time)

            s.price = q?.price
            s.last_price = q?.last_price
            s.time = q?.time
            s.gain = s.price - s.last_price
            s.gainRelative = s.gain / s.last_price
            s.up = s.price >= s.last_price

            s.owners ?= []
            s.owners.push(i)
              
            i.value += shares * s.price
            i.last_value += shares * s.last_price
        
        i.gain = i.value - i.last_value
        i.gainRelative = i.gain / i.last_value
        i.up = i.value >= i.last_value


      # Price history for each stock
      for s in stocks
        s.history = {}
        for q in Quotes.latest(s.symbol, null, 15)
          s.history[q.time] = q

      ###
      Plan: pick the times for which we want data on the graph.
      For each time, grab stock's price and investor's value
      Factor this out to a separate publish function that's much less frequent
      ###

      # Send to client
      for i in investors
        @changed('investors',i._id,i)

      for s in stocks
        @changed('stocks',s._id,s)

    publishTimer('prices',updatePrices)


    # Publish past quotes for debugging
    Meteor.publish(null,-> Quotes.find({},{limit: 50, sort: {time: -1}}))



  if Meteor.isClient
    Deps.autorun ->
      safeSubscribe('prices',Session.get('timeLagStable'))





