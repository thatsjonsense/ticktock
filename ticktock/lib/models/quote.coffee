@Quotes = new Meteor.Collection('quotes')
@History = new Meteor.Collection('history')

if Meteor.isServer
  Quotes._ensureIndex {time: -1}


Quotes.latest = (symbol, time = do defaultTime) ->
  q = Quotes.findOne
    symbol: symbol
    time: {$lte: time}
  ,
    sort: {time: -1}
    limit: 1
  return quoteDetails(q)

Quotes.history = (symbol,start,end,interval) ->
  times = intervalTimes(start,end,interval)

  quotes = _.map times, (t) -> 
    q = Quotes.latest(symbol,t)
    q?.time = t
    return q

  return _.compact quotes

intervalTimes = (start,end,interval) ->
  t = start
  times = []
  while t < end
    times.push t
    t = secondsAfter t, interval
  times.push end
  times = _.uniq times

quoteDetails = (q) ->
  if q and q.price? and q.last_price?
    'price': q.price
    'last_price': q.last_price
    'time': q.time
    'gain': q.price - q.last_price
    'gainRelative': (q.price - q.last_price) / (q.last_price)
    'up': q.price >= q.last_price
  else
    null


Meteor.startup ->

  if Meteor.isServer



    updateHistory = (start,end,interval_minutes = 15) ->

      investors = Investors.find().fetch()
      stocks = Stocks.find().fetch()

      for s in stocks
        quotes = Quotes.history(s.symbol,start,end,interval_minutes*60)
        quotes = _.map quotes, quoteDetails

        #debug "Changed stock #{s.symbol}'s history to #{quotes.length} quotes"
        @added('history',s._id,{'history': quotes})

    publishTimer('history',updateHistory,null,5000,false)


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
        i.portfolio = {}
        i.pie = {}

        for symbol, shares of i.symbolsOwnedAt(time)
          #print "#{i.name} owns #{symbol}"
          s = _.findWhere stocks, {symbol: symbol}
          if not s then continue

          # Get price data, etc. from latest quote
          q = Quotes.latest(symbol, time)
          _.extend(s, quoteDetails q)

          s.owners ?= []
          s.owners.push(i)
            
          i.portfolio[symbol] = shares * s.price
          i.value += shares * s.price
          i.last_value += shares * s.last_price
        
        i.gain = i.value - i.last_value
        i.gainRelative = i.gain / i.last_value
        i.up = i.value >= i.last_value
        for symbol, value of i.portfolio
          i.pie[symbol] = value / i.value

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
      day = Stock.lastTradingDay()
      safeSubscribe('history',Stock.tradingOpen(day),Stock.tradingClose(day),1)





