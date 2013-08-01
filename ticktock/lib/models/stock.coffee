# General info about stocks

@Stocks = new Meteor.Collection('stocks',
  transform: (doc) ->
    s = new Stock(doc)
)

checkFresh = (quote,time) ->
  if quote? and quote.time >= minutesBefore(time,1000)
    return parseFloat(q.price)

class Stock
  constructor: (doc) -> _.extend(@,doc)

  quotesSince: (time) ->
    Quotes.find
      symbol: @symbol
      time:
        $gte: time

  quoteNow: ->
    Quotes.findOne({symbol: @symbol},{sort: {time: -1}})

  quoteAt: (time) ->
    Quotes.findOne({symbol: @symbol, time: {$lte: time}},{sort: {time: -1}})

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
    if q? and q.time >= minutesBefore(time,1000) then parseFloat(q.price) else null


  # warning: this guy won't react well, because end date gets stored and updates after aren't reactive
  getPriceHistory: (start,end) ->
    q = Quotes.find
      symbol: @symbol,
      time: {$lte: end, $gte: start}


  getPriceAtTime: (time) ->
    
    q = Quotes.findOne
      symbol: @symbol
      time: {$lte: time}
    ,
      {sort: {time: -1}}
    
    if q? and q.time >= minutesBefore(time,1000) #freshness needed
      return parseFloat(q.price)
    else
      return null # No fresh quote. In the future, we could live call for it