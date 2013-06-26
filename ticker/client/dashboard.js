Users = new Meteor.Collection("users");
Stocks = new Meteor.Collection("stocks");

Template.dashboard.users = function () {
  return Users.find({}, {sort: {name: 1}});
};

Template.user.value = function () {
  var total = 0;
  _.each(this.investments,function (i) {
    var stock = Stocks.findOne({'symbol': i.symbol})
    if (stock) {
      console.log('Looking up symbol',i.symbol,'found',stock)
      var price = stock.price
      total += (i.shares * price);
    }
  })

  return total.toFixed(2);
}