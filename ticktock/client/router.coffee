Meteor.Router.add
  '/stocks': 'dashboard_stocks'
  '': 'dashboard_investors'
  '/chart': 'chart'

  '/portfolio/:id': (id) ->
    Session.set('viewingUserId',id)
    return 'dashboard_stocks'



Meteor.Router.beforeRouting = -> Session.set('viewingUserId',null)