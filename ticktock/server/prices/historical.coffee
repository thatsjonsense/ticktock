

Meteor.Router.add
  '/historical/:symbol/:days': (symbol,days) -> 
    loadHistoricalQuoteGoogle(symbol,days)
    prettify Prices.find({symbol: symbol}).fetch()
  '/historical/dump': -> # todo: output all historical data to a .json file which we can save


loadHistoricalQuoteGoogle = (symbol,days = 1,interval = 60) ->

  googleUrl = "http://www.google.com/finance/getprices?i=#{interval}&p=#{days}d&f=d,o,h,l,c,v&df=cpct&q=#{symbol}"

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

    data =
      symbol: symbol
      time: secondsAfter(current_day, interval * n) 
      price: cols[1] # closing price

    Prices.findOrInsert(data)