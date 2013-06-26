Session.setDefault('user_id',null);

Template.dashboard.mode_stocks = function () {
  return Session.get('user_id') ? true : false;
}

Template.dashboard.mode_users = function () {
  return Session.get('user_id') ? false : true;
}

// Track selected user in user_list
var DashboardRouter = Backbone.Router.extend({
  routes: {
    "user/:user_id": "selectUser",
    "": "allUsers"
  },
  selectUser: function (user_id) {
    Session.set("user_id", user_id);
  },
  allUsers: function () {
    Session.set("user_id",null)
  },
  setUser: function (user_id) {
    this.navigate('user/' + user_id, {trigger: true, replace: false});
  }
});

Router = new DashboardRouter;

Meteor.startup(function () {
  Backbone.history.start({pushState: true});
});