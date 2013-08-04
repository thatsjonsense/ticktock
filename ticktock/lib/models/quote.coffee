@Quotes = new Meteor.Collection('quotes')


Meteor.startup ->

  # Publishing
  if Meteor.isServer

    NUM_BEFORE = 10
    NUM_AFTER = 10
    INTERVAL = 1 # seconds between user-facing updates
    SERVER_INTERVAL = 1 # seconds between client/server handshake

    pubQuotes = (symbol,delay) ->

      @onStop ->
        if @timer then Meteor.clearInterval(@timer)

      @quotes = []

      #print "Publishing #{symbol} to client"

      @timer = Meteor.setInterval(=>

        query = Ticks.find
          symbol: symbol
          time: {$lte: secondsAgo(delay - (NUM_AFTER * INTERVAL))}
        ,
          limit: NUM_BEFORE + NUM_AFTER
          sort: {time: -1}
        
        ticks = query.fetch()

        # Find items in client that aren't in server, and remove them
        for quote in @quotes
          
          id = quote._id
          if not _.findWhere(ticks, {_id: id})
            #print "Removing #{id} because it wasn't in quotes"
            @quotes = _.without(@quotes,quote)
            @removed('quotes',id)

        # Find items on server that aren't on client, and add them
        for tick in ticks
          id = tick._id
          if not _.findWhere(@quotes, {_id: id})
            #print "Adding #{id} because it wasn't in buffer"

            stock = Stock.lookup(tick.symbol)
            time = tick.time
            price = tick.price
            last_price = stock.prevCloseTick(time)?.price

            quote =
              _id: id
              symbol: tick.symbol
              time: tick.time
              price: tick.price
              last_price: last_price
              gain: if last_price then (price - last_price) else null
              gainRelative: (price - last_price) / last_price
            
            @quotes.push(quote)
            @added('quotes',id,quote)

      ,SERVER_INTERVAL * 1000)

    Meteor.publish('Stock.quotes', pubQuotes)

  # Subscribing
  if Meteor.isClient
    
    Deps.autorun ->
      for stock in Stocks.find().fetch()
      #for stock in Stocks.find({symbol: 'MSFT'}).fetch()
        print 'Subscribing to ' + stock.symbol + ' with delay ' + Session.get('timeLag')
        Meteor.subscribe('Stock.quotes',stock.symbol,Session.get('timeLag'))


