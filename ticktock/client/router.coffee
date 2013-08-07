Meteor.Router.add
  '/stocks': 'dashboard_stocks'
  '/users': 'dashboard_investors'
  '/chart': 'chart'


Meteor.Router.beforeRouting = -> Session.set('user_id',null)