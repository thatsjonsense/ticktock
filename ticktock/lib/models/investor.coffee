@Investors = new Meteor.Collection('investors',
  transform: (doc) ->
    i = new Investor(doc)
    i.currentValue = 0 if not i.currentValue?
    i.prevValue = 0 if not i.prevValue?
    return i
)

class Investor
  constructor: (doc) -> _.extend(@,doc)

  stocksOwned: (time) ->
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


Meteor.Router.add(
  '/test/models/investor/:n/:d': (n,d) -> 
    prettify(Investors.findOne({name: n}).stocksOwned(MOCK_DATES[d]))

  '/test/models/investor': ->
    prettify(Investors.findOne({name: "Jon"}).stocksOwned(MOCK_DATES.fri))
)