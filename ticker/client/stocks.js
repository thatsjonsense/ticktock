Session.setDefault('adding_stock',false)

Template.stock_list.stocks = function () {
  var current_user = Users.findOne(Session.get('user_id'))
  if (current_user) {
    return current_user.stocks()  
  }
};

Template.stock.delta = function () {
  var ret = (this.price - this.open).toFixed(2);
  return (ret >= 0 ? "+" : "") + ret;
}

Template.stock.deltaPercent = function () {
  return (100 * (this.price - this.open) / this.open).toFixed(2) + "%";
}

Template.stock.updown = function () {
  // TODO: somehow, I feel this should be tied with stock.delta
  return this.price >= this.open ? "up": "down";
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
