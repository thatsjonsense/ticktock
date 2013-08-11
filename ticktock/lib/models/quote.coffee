@Quotes = new Meteor.Collection('quotes')

if Meteor.isServer
  Quotes._ensureIndex {time: -1}


Quotes.latest = (symbol, time = do defaultTime) ->
  Quotes.findOne
    symbol: symbol
    time: {$lte: time}
  ,
    sort: {time: -1}


Meteor.startup ->

  if Meteor.isServer

    InvestorsAndStocks =
      setup: ->
        @investors = Investors.find().fetch()
        @stocks = Stocks.find().fetch()

        for investor in @investors
          @added('investors',investor._id,investor)

        for stock in @stocks
          @added('stocks',stock._id,stock)

      update: (delay) ->
        time = secondsAgo(delay)

        for i in @investors
          i.value = 0
          i.last_value = 0

          for symbol, shares of i.symbolsOwnedAt(time)
            s = Stocks.findOne {symbol: symbol}

            q = Quotes.latest(symbol, time)

            s.price = q.price
            s.last_price = q.last_price
            s.gain = s.price - s.last_price
            s.gainRelative = s.gain / s.last_price
            s.up = s.price >= s.last_price
            @changed('stocks',s._id,s)
              
            i.value += shares * q.price
            i.last_value += shares * q.last_price
          
          i.gain = i.value - i.last_value
          i.gainRelative = i.gain / i.last_value
          i.up = i.value >= i.last_value
          @changed('investors',i._id,i)    

    publishTimer('investorsAndStocks2',InvestorsAndStocks.setup,InvestorsAndStocks.update,1000)


  if Meteor.isClient
    
    safeSubscribe('investorsAndStocks2',Session.get('timeLagStable'))





