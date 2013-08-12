

class @GoogleFinance

  @getQuotesPast = (stock,days = 1,interval = 60) ->
    days = parseInt(days) + 1

    googleUrl = "http://www.google.com/finance/getprices?i=#{interval}&p=#{days}d&f=d,o,h,l,c,v&df=cpct&q=#{stock.symbol}"

    response = Meteor.http.get(googleUrl)
    lines = response.content.split('\n').slice(7,-1) # remove header and last line

    current_day = null
    last_close = null
    last_quote = null
    for line in lines
      cols = line.split(',')

      if cols[0][0] == 'a'
        last_close = last_quote?.price
        timestamp = cols[0].slice(1)
        current_day = dateFromUnix(timestamp)
        n = 0
      else
        n = cols[0]

      quote =
        symbol: stock.symbol
        time: secondsAfter(current_day, interval * n) 
        price: parseFloat(cols[1]) # closing price
        last_price: last_close
        source: 'historical'

      last_quote = quote
      Quotes.findOrInsert(quote)




Meteor.Router.add
  '/historical/:symbol/:days': (symbol,days) -> 
    if symbol == 'all'
      t = []
      for stock in active_stocks
        print "hitting google for #{stock.symbol}"
        t.push GoogleFinance.getQuotesPast(stock,days)
      prettify q
    else
      prettify GoogleFinance.getQuotesPast(Stock.lookup(symbol),days)
  '/historical/dump': -> # todo: output all historical data to a .json file which we can save
