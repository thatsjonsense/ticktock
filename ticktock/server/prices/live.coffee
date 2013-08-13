


class @YahooFinance

  @getQuote: (stock) ->

    yahooUrl = "http://query.yahooapis.com/v1/public/yql?q=select%20symbol%2C%20LastTradeTime%2C%20LastTradeDate%2C%20LastTradePriceOnly%2C%20PreviousClose%20from%20yahoo.finance.quotes%20where%20symbol%20%3D%20'#{stock.symbol}'&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="

    query_time = now()
    response = Meteor.http.get(yahooUrl)
    y_quote = response.data?.query?.results?.quote

    if response.statusCode == 200 and y_quote
      quote =
        symbol: stock.symbol
        time: @parseDateTime(y_quote.LastTradeDate, y_quote.LastTradeTime)
        price: parseFloat(y_quote.LastTradePriceOnly)
        last_price: parseFloat(y_quote.PreviousClose)
        source: 'live'
      Quotes.findOrInsert(quote)
      return quote
    else
      debug 'Problem getting quote from Yahoo'
      debug response
      return null


  @parseDateTime = (date, time) ->
    d = Date.create(date + ' ' + time)
    pst = hoursBefore(d,3)
    return d


  @getStockInfo = (symbol) ->


###
Meteor.Router.add
  '/live/:symbol': (symbol) -> 
    prettify TickSourceYahoo.getTick(Stock.lookup(symbol))
###

 # http://developer.yahoo.com/yql/console/?q=show%20tables&env=store://datatables.org/alltableswithkeys#h=select%20symbol%2C%20LastTradeTime%2C%20LastTradeDate%2C%20LastTradePriceOnly%20from%20yahoo.finance.quotes%20where%20symbol%20%3D%20%27GOOG%27
    