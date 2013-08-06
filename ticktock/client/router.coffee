Meteor.Router.add
  '/stocks': 'dashboard_stocks'
  '/users': 'dashboard_investors'


Meteor.Router.beforeRouting = -> Session.set('user_id',null)