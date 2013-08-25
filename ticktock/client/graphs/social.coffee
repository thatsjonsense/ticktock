Template.social.investors = ->
  investors = Investors.find().fetch()
  for i in investors
    if i._id == Session.get('viewingUserId')
      i.current = true
    else
      i.current = false
  return investors