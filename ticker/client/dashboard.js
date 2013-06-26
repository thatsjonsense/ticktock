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

Template.user.events({
  'click': function () {
    Router.setUser(this._id)
  }
})


Template.stock_list.stocks = function () {
  //return Stocks.find({}, {sort: {name: -1}});
  var current_user = Users.findOne(Session.get('user_id'))
  if (current_user) {
    return current_user.stocks()  
  }
};

Template.stock.delta = function () {
  return (100 * (this.price - this.open) / this.open).toFixed(2) + "%";
}

Template.stock.updown = function () {
  // TODO: somehow, I feel this should be tied with stock.delta
  return this.price >= this.open ? "up": "down";
}


// Track selected user in user_list
var UsersRouter = Backbone.Router.extend({
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

Router = new UsersRouter;

Meteor.startup(function () {
  Backbone.history.start({pushState: true});
});