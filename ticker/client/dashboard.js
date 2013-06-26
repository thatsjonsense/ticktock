Users = new Meteor.Collection("users");
Stocks = new Meteor.Collection("stocks");

Template.dashboard.users = function () {
  return Users.find({}, {sort: {value: -1}});
};

Template.user.value = function () {
  return this.value.toFixed(2)
}