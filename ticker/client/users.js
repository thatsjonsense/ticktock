
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
