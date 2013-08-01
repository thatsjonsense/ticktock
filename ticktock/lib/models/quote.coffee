@Quotes = new Meteor.Collection("prices")

@getPriceAtTime = (symbol,time) ->
  
  q = Quotes.findOne
    symbol: symbol
    time: {$lte: time}
  ,
    {sort: {time: 1}}
  

  if q? and q.time >= time.minutesBefore(1)
    return q.price
  else
    return null # No fresh quote. In the future, we could live call for it

Meteor.Router.add(
  '/test/prices': -> prettify(getPriceAtTime('GOOG',new Date("2013-07-30T19:21:00.000Z")))
  '/test/prices/:s/:d': (s,d) -> prettify(getPriceAtTime(s,new Date(d)))
)