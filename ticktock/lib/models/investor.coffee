@Investors = new Meteor.Collection('investors',
  transform: (doc) ->
    i = new Investor(doc)
    return i
)

class @Investor
  constructor: (doc) -> 
    _.extend(@,doc)

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

  history: ->
    History.find({investor: @_id}).fetch() or []