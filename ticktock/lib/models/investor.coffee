@Investors = new Meteor.Collection('investors',
  transform: (doc) ->
    i = new Investor(doc)
    i.currentValue = 0 if not i.currentValue?
    i.prevValue = 0 if not i.prevValue?
    return i
)

class @Investor
  constructor: (doc) -> 
    _.extend(@,doc)
    @latest_quote = new Deps.injective(null)

  @lookup: (name) ->
    Investors.findOne({name: name})

  symbolsOwnedAt: (time = do defaultTime) ->
    "Return a dictionary SYMBOL -> SHARES_OWNED for any given TIME"
    p = {}
    trades_so_far = (t for t in @trades when t.date <= time)
    trades_by_symbol = _.groupBy(trades_so_far, (t) -> t.symbol)
    for symbol, trades of trades_by_symbol
      p[symbol] ?= 0
      p[symbol] += t.shares for t in trades when t.type is 'buy'
      p[symbol] -= t.shares for t in trades when t.type is 'sell'
      if p[symbol] == 0 then delete p[symbol]

    return p

  symbolsOwnedEver: -> (t.symbol for t in @trades)

  latestQuote: (time = do defaultTime) ->

      current = 0
      previous = 0

      for symbol, shares of @symbolsOwnedAt(time)
        s = Stock.lookup(symbol)
        q = s.latestQuote(time)

        current += shares * q?.price
        previous += shares * q?.last_price

      quote =
        _id: @_id + time
        user_id: @_id
        time: time
        price: current
        last_price: previous
        gain: if previous then (current - previous) else null
        gainRelative: (current - previous) / previous
        up: current >= previous



# publish to everyone

if Meteor.isServer
  Meteor.publish('Investors.all',-> Investors.find())

if Meteor.isClient
  Meteor.subscribe('Investors.all')





Meteor.Router.add(
  '/test/models/investor/:n/:d': (n,d) -> 
    prettify(Investors.findOne({name: n}).stocksOwned(MOCK_DATES[d]))

  '/test/models/investor': ->
    prettify(Investors.findOne({name: "Jon"}).stocksOwned(MOCK_DATES.fri))
)