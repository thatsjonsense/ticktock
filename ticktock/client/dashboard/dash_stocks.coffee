
Template.dashboard_stocks.stocks = ->
  stocks = Stocks.findOrInsert({symbol: symbol}) for symbol in ['GOOG','MSFT','LNKD']
 
  # Todo: get a list of all the active stocks we're tracking

Template.dashboard_stocks.quotes = ->
  prettify(Quotes.find({},{limit: 10}).fetch())


Template.stock_row.symbol = -> @symbol
  
