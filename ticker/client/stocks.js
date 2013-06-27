Session.setDefault('adding_stock',false)

Template.stock_list.stocks = function () {
  var current_user = Users.findOne(Session.get('user_id'))
  if (current_user) {
    var stocks = current_user.stocks()
    return _.sortBy(stocks,function(stock) {
      return -stock.deltaRelative()
    })
  }
};

Template.stock_list.title = function () {
  var current_user = Users.findOne(Session.get('user_id'))
  if (current_user) {
    return current_user.name + "'s portfolio";
  }
}

Template.stock.updown = function () {
  return this.deltaAbsolute() >= 0 ? "up": "down";
}


// Adding a new stock to portfolio
Template.stock_control.adding_stock = function () {
  return Session.get('adding_stock')
}

Template.stock_control.events({
	'click .add_stock': function (evt) {
		Session.set('adding_stock',true)
	},

	'click .submit': function (evt) {
		Users.update(
			Session.get('user_id'),
			{$push: {investments: {
				symbol: $('.new_stock .symbol').val(),
				shares: $('.new_stock .shares').val(),
				cost_basis: $('.new_stock .cost_basis').val()
			}}})
	}
})
