
Template.dashboard_stocks.stocks = ->
  viewing_user = Investors.findOne Session.get('viewingUserId')
  if viewing_user
    return Stocks.find
      symbol:
        $in: _.keys(viewing_user.symbolsOwnedAt())
    .fetch()

  else
    return Stocks.find().fetch()
    

Template.dashboard_stocks.title = ->
  viewing_user = Investors.findOne Session.get('viewingUserId')
  if viewing_user
    return viewing_user.name + "'s Portfolio"
  else
    return "All Stocks"



Template.stock_row.owners = ->
  _.reject(@owners,(i) -> i._id == Session.get('viewingUserId'))


Template.stock_row.preserve ['a','table','tbody','tr','td']

Template.stock_row.updown = ->
  if @up then "up" else "down"



# Adding a new stock to portfolio
Template.stock_control.events
  'click #add_stock': (evt) ->
    $('#new_stock').show()
    $('#add_stock').hide()
    $('#new_stock .symbol').val('').focus()
  
  'blur #new_stock input': (evt) ->
    # if all of the fields are blank, clear
    if $('#new_stock .symbol').val() == "" and $('#new_stock .shares').val() == "" and $('#new_stock .cost_basis').val() == ""
      $('#new_stock').hide()
      $('#add_stock').show()
    
  'click .submit': (evt) ->
    Investors.update(
      Session.get('viewingUserId')
    ,
      $push:
        trades:
          type: 'buy'
          symbol: $('#new_stock .symbol').val()
          shares: $('#new_stock .shares').val()
          cost: $('#new_stock .cost_basis').val()
          date: virtualTime()
    )

    # clear values out of control and bring back focus
    $('#new_stock .symbol').val('').focus()
    $('#new_stock .shares').val('')
    $('#new_stock .cost_basis').val('')

