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