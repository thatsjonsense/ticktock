Meteor.Router.add
  
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

  'dashboard/stocks': 'dashboard_stocks'
  'dashboard/investors': 'dashboard_investors'
  'dashboard/portfolio/:id': (id) ->
    Session.set('viewingUserId',id)
    return 'dashboard_stocks'

  '/infographic': 'infographic'


  '': 'overview'
  '/portfolio/:id' : (id) ->
    Session.set('viewingUserId',id)
    return 'overview'




Meteor.Router.beforeRouting = -> 
  Session.set('viewingUserId',null)