

@currentInvestor = (reactive=true) ->
  
  if reactive
    investor_id = Session.get('viewingUserId')
    investor = Investors.findOne investor_id
  else
    Deps.nonreactive ->
      investor_id = Session.get('viewingUserId')
      investor = Investors.findOne investor_id

  return investor