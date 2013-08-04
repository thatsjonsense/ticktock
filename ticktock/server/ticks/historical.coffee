

class @TickSourceGoogle

  @getTicksPast = (stock,days = 1,interval = 60*15) ->

    googleUrl = "http://www.google.com/finance/getprices?i=#{interval}&p=#{days}d&f=d,o,h,l,c,v&df=cpct&q=#{stock.symbol}"

    response = Meteor.http.get(googleUrl)
    lines = response.content.split('\n').slice(7,-1) # remove header and last line

    current_day = null
    for line in lines
      cols = line.split(',')

      if cols[0][0] == 'a'
        timestamp = cols[0].slice(1)
        current_day = dateFromUnix(timestamp)
        n = 0
      else
        n = cols[0]

      tick =
        symbol: stock.symbol
        time: secondsAfter(current_day, interval * n) 
        price: cols[1] # closing price

      Ticks.findOrInsert(tick)


Meteor.Router.add
  '/historical/:symbol/:days': (symbol,days) -> 
    if symbol == 'all'
      t = []
      for stock in active_stocks
        print "hitting google for #{stock.symbol}"
        t.push TickSourceGoogle.getTicksPast(stock,days)
      prettify q
    else
      prettify TickSourceGoogle.getTicksPast(Stock.lookup(symbol),days)
  '/historical/dump': -> # todo: output all historical data to a .json file which we can save
