Users = new Meteor.Collection("users", {
  transform: function (doc) { return new User(doc); }
});

// stock class
function User (doc) {
  _.extend(this, doc);
};

_.extend(User.prototype, {
  stocks: function () {
    var self = this;
    return _.map(self.investments, function(i) {
      var stock = Stocks.findOne({symbol: i.symbol}) || {}
      stock.shares = i.shares
      stock.cost_basis = i.cost_basis
      return stock
    })
  },

  totalValue: function () {
    var self = this
    var value = _.reduce(self.stocks(), function(sum,stock) {
      return sum + (stock.shares * stock.price)
    }, 0.0)
    //console.log('Calculated value',value)
    return value
  }

});



if (Meteor.isServer) {

  // Keep portfolio values up to date
  Meteor.setInterval(function () {
    userCursor = Users.find({});
    userCursor.forEach(function (user) {
      total = user.totalValue()
      Users.update(user._id, {$set: {value: total}})
    });
  }, 5000)




}



/*
USER_SCHEMA = {
  name: 'Jon',
  investments: [
    {
      symbol: 'GOOG',
      shares: 10,
      cost_basis: 100
    },
    value: 100
    ...
  ]
}

*/