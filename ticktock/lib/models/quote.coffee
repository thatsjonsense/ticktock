@Quotes = new Meteor.Collection('quotes')

if Meteor.isServer
  Quotes._ensureIndex {time: -1}


Quotes.latest = (symbol, time = do defaultTime) ->
  q = Quotes.findOne
    symbol: symbol
    time: {$lte: time}
  ,
    sort: {time: -1}
    limit: 1


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

      for i in investors
        i.value = 0
        i.last_value = 0

        for symbol, shares of i.symbolsOwnedAt(time)
          #print "#{i.name} owns #{symbol}"
          s = _.findWhere stocks, {symbol: symbol}

          q = Quotes.latest(symbol, time)

          s.price = q?.price
          s.last_price = q?.last_price
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

      for i in investors
        @changed('investors',i._id,i)

      for s in stocks
        @changed('stocks',s._id,s)

    publishTimer('prices',updatePrices)



  if Meteor.isClient
    Deps.autorun ->
      safeSubscribe('prices',Session.get('timeLagStable'))





