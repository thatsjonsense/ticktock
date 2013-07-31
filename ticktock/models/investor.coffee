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

		return p



Meteor.Router.add(
	'/test/models/investor/:d': (d) ->

		dates =
			d1: new Date(1375255370000)
			d2: new Date(1375255370001)
			d3: new Date(1375255370002)
			d4: new Date(1375255370003)
			d5: new Date(1375255370004)

		id = Investors.insert(
			name: 'Jon'
			picture: 'whatever.jpg'
			trades: [
				{
					type: 'buy'
					symbol: 'MSFT'
					shares: 100
					cost: 33.25
					date: dates.d1
				},
				{
					type: 'buy'
					symbol: 'MSFT'
					shares: 50
					cost: 31.0
					date: dates.d2
				},
				{
					type: 'buy'
					symbol: 'GOOG'
					shares: 10
					cost: 700
					date: dates.d3
				},
				{
					type: 'sell'
					symbol: 'MSFT'
					shares: 80
					cost: 36.5
					date: dates.d4
				},
				{
					type: 'buy'
					symbol: 'MSFT'
					shares: 50
					cost: 25.0
					date: dates.d5
				},
			]

		)
		i = Investors.findOne(id)
		output = i.stocksOwned(dates[d])
		Investors.remove(id)
		return prettify(output)
)

###

Investor =
	name: 'Jon'

	picture: 'http://facebook.com/.../whatever.jpg'

	trades: [
		{
			type: buy,
			symbol: MSFT,
			shares: 100,
			cost: 33.25,
			date: <date object>
		}
	]












###