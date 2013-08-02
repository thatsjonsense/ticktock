# General info about stocks

@Quotes = new Meteor.Collection('quotes')
@Stocks = new Meteor.Collection('stocks',
  transform: (doc) ->
    s = new Stock(doc)
)

checkFresh = (quote,time) ->
  if quote? and quote.time >= minutesBefore(time,1000)
    return parseFloat(q.price)

class @Stock
  constructor: (doc) -> _.extend(@,doc)

  @lookup: (symbol) -> Stocks.findOrInsert({symbol: symbol})

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

