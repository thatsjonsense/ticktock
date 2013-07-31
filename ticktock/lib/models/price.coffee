@Prices = new Meteor.Collection("prices")

@getPriceAtTime = (symbol,date) ->
  
  # Todo: sort to find the narrowest time range. Otherwise, this could get 1-day data
  p = Prices.findOne({
    symbol: symbol
    open_date: {$lt: date}
    close_date: {$gte: date}
  })

  if p?
    return p.close
  else
    return null

Meteor.Router.add(
  '/test/prices': -> prettify(getPriceAtTime('GOOG',new Date("2013-07-30T19:21:00.000Z")))
  '/test/prices/:s/:d': (s,d) -> prettify(getPriceAtTime(s,new Date(d)))
)