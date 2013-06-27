Session.setDefault('user_id',null);


Template.user_list.users = function () {
	var users = Users.find({}).fetch()
	var sorted = _.sortBy(users,function(user) {
   return SORT_TYPE == 'delta' ? -user.deltaRelative() : -user.currentValue
	})
  return sorted
};



Template.user.preserve({
  'tr': function (node) { return node.id; }
});


Template.user.updown = function () {
  return this.deltaAbsolute() >= 0 ? "up": "down";
}


Template.user.events({
  'click': function () {
    Router.setUser(this._id);
  }
});


// TODO: maybe move these to more generic file
Template.dashboard.title = function () {
  // get user in focus if applicable
  
};