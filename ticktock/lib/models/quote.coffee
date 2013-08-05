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





arrayDiff = (array_old,array_new,properties) ->
  "Return a list of elements added and removed from ARRAY_OLD to make ARRAY_NEW"
  "If properties is null, will compare based on all of them."

  properties ?= (elt) -> elt

  added = []
  removed = []

  for elt in array_new
    if not _.findWhere(array_old,properties(elt))
      #print "Couldn't find #{prettify properties(elt)} in #{array_old}"
      added.push(elt)

  for elt in array_old
    if not _.findWhere(array_new,properties(elt))
      removed.push(elt)

  return [added, removed]



Meteor.startup ->

  # Publishing
  if Meteor.isServer

    NUM_BEFORE = 10
    NUM_AFTER = 10
    INTERVAL = 1 # seconds between user-facing updates
    SERVER_INTERVAL = 1 # seconds between client/server handshake

    pubLatestQuotes = (symbol,delay) ->

      # Sadly, this won't trigger if a client refreshes. So we can get ghost subscriptions.
      @onStop =>
        if @timer
          Meteor.clearInterval(@timer)

      @quotes = [] # list of all the stuff the client is holding onto

      #print "Publishing #{symbol} to client"

      @timer = Meteor.setInterval(=>

        #print "Running timer in pub #{@_session.id} for #{symbol} on delay #{delay}"

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
            print "Removing #{id} because it wasn't in ticks"
            #print quote.symbol, quote.time, quote.price
            @quotes = _.without(@quotes,quote)
            @removed('quotes',id)

        # Find items on server that aren't on client, and add them
        for tick in ticks
          id = tick._id
          if not _.findWhere(@quotes, {_id: id})
            print "Adding #{id} because it wasn't in buffer"

            quote = quoteFromTick(tick)
            
            @quotes.push(quote)
            @added('quotes',id,quote)

      ,SERVER_INTERVAL * 1000)

    Meteor.publish('Stock.latestQuotes', pubLatestQuotes)


    # Problem: not live updating yet, need to fix that
    pubPastQuotes = (symbol, start, end, interval) ->


      check(symbol,String)
      check(start,Number)
      check(end,Number)
      check(interval,Number)      
      check(start, Match.Where (x) -> x <= 0)
      check(end, Match.Where (x) -> start <= x)

      stock = Stock.lookup(symbol)


      @onStop =>
        if @timer then Meteor.clearInterval(@timer)

      @local = []
      @timer = Meteor.setInterval(=>

        # Generate a new quote for each moment over that interval

        new_quotes = []
        for lag in [start...end] by interval
          tick = stock.latestTick(secondsAgo(-lag))
          quote = quoteFromTick(tick)
          quote._id += 'keep'
          #print lag, secondsAgo(-lag), quote.time, quote.price
          new_quotes.push(quote)

        new_quotes = _.uniq(new_quotes,false,(q) -> q._id)

        [added, removed] = arrayDiff(@local,new_quotes, (q) -> {_id: q._id})
        
        #print 'Local', prettify @local
        #print 'New', prettify new_quotes
        #print 'Diff', prettify arrayDiff(@local,new_quotes, (q) -> {_id: q._id})

        for quote in added
          print "Adding #{quote._id} to local because it's new in new_quotes"
          @local.push(quote)
          @added('quotes',quote._id,quote)

        for quote in removed
          print "Removing #{quote._id} from local because it wasn't in new_quotes"
          @local = _.without(@local,quote)
          @removed('quotes',quote._id)

      ,SERVER_INTERVAL * 1000)




      return

    Meteor.publish('Stock.pastQuotes', pubPastQuotes)


  # Subscribing
  if Meteor.isClient
    
    Deps.autorun ->
      #for stock in Stocks.find().fetch()
      for stock in Stocks.find({symbol: 'MSFT'}).fetch()
        print 'Subscribing to ' + stock.symbol + ' with delay ' + Session.get('timeLag')
        Meteor.subscribe('Stock.latestQuotes',stock.symbol,Session.get('timeLag'))

    Deps.autorun ->
      if max? and interval?
        #for stock in Stocks.find().fetch()
        for stock in Stocks.find({symbol: 'MSFT'}).fetch()
          print 'Subscribing to ' + stock.symbol + ' for stock.pastQuotes'
          Meteor.subscribe('Stock.pastQuotes',stock.symbol,-max,0,interval)
