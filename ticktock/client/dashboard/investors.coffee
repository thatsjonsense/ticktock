

Template.dashboard_investors.investors = ->
  investors = Investors.find({}).fetch()
  
  Deps.autorun ->
    for investor in investors
      q = investor.latestQuote()
      investor.latest_quote.set q

  return investors
  
  # Todo: get a list of all the active stocks we're tracking

Template.dashboard_investors.quotes = ->
  Quotes.find
    symbol: 'MSFT'
  ,
    sort:
      type: 1
      time: -1
    limit: 100


Template.investor_row.updown = ->
  if @latest_quote.get()?.gain >= 0 then "up" else "down"


Template.investor_row.currentValue = ->
  @latest_quote.get()?.price

Template.investor_row.currentGain = -> @latest_quote.get()?.gain

Template.investor_row.currentGainRelative = -> @latest_quote.get()?.gainRelative