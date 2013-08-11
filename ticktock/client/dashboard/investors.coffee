

Template.dashboard_investors.investors = ->
  investors = Investors.find({}).fetch()
  
  # Todo: get a list of all the active stocks we're tracking

Template.dashboard_investors.quotes = ->
  Quotes.find
    symbol: 'MSFT'
  ,
    sort:
      type: 1
      time: -1
    limit: 100


Template.investor_row.updown = -> if @up then "up" else "down"

Template.investor_row.currentValue = -> @value

Template.investor_row.currentGain = -> @gain

Template.investor_row.currentGainRelative = -> @gainRelative