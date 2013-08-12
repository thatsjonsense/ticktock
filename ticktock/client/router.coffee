Meteor.Router.add
  '/stocks': 'dashboard_stocks'
  '': 'dashboard_investors'
  
  '/chart': ->
    Session.set('chartMode','investors')
    'chart'

  '/chart/stocks': ->
    Session.set('chartMode','stocks')
    return 'chart'

  '/chart/portfolio/:id': (id) ->
    Session.set('viewingUserId',id)
    Session.set('chartMode','stocks')
    return 'chart'

  '/portfolio/:id': (id) ->
    Session.set('viewingUserId',id)
    return 'dashboard_stocks'



Meteor.Router.beforeRouting = -> 
  Session.set('viewingUserId',null)