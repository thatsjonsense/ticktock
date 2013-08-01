Meteor.Router.add
  '/stocks': 'dashboard_stocks'


Meteor.Router.beforeRouting = -> Session.set('user_id',null)