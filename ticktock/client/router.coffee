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

  '/infographic': 'infographic'

  '/lines': 'two_pane'

  '/lines/:id': (id) ->
    Session.set('viewingUserId',id)
    return 'two_pane'



Meteor.Router.beforeRouting = -> 
  Session.set('viewingUserId',null)