Users = new Meteor.Collection("users");
Stocks = new Meteor.Collection("stocks");

Session.setDefault('user_id',null);

Template.dashboard.mode_stocks = function () {
  return Session.get('user_id') ? true : false;
}

Template.dashboard.mode_users = function () {
  return Session.get('user_id') ? false : true;
}


Template.user_list.users = function () {
  return Users.find({}, {sort: {value: -1}});
};

Template.user.value = function () {
  return this.value.toFixed(2)
}


Template.stock_list.stocks = function () {
  return Stocks.find({}, {sort: {name: -1}});
};


// Track selected user in user_list
var UsersRouter = Backbone.Router.extend({
  routes: {
    "user/:user_id": "selectUser"
  },
  selectUser: function (user_id) {
    var oldUser = Session.get("user_id");
    console.log('Routing to user',user_id)
    if (oldUser !== user_id) {
      Session.set("user_id", user_id);
    }
  },
  setUser: function (user_id) {
    this.navigate('user/' + user_id, true);
  }
});

Router = new UsersRouter;

Meteor.startup(function () {
  Backbone.history.start({pushState: true});
});