Users = new Meteor.Collection("users", {
  transform: function (doc) { return new User(doc); }
});

// user class
function User (doc) {
  _.extend(this, doc);
};

_.extend(User.prototype, {
  stocks: function () {
    var self = this;
    var stocks = [];


    _.each(self.investments, function(i) {
      var stock = Stocks.findOne({symbol: i.symbol})
      if (stock) {
        stock.shares = i.shares
        stock.cost_basis = i.cost_basis
        stocks.push(stock)
      }
    })

    return stocks;
  },

  currentValue: function () {
    var self = this
    var value = _.reduce(self.stocks(), function(sum,stock) {
      return sum + (stock.shares * stock.price)
    }, 0.0)
    //console.log('Calculated value',value)
    return value
  },

  prevValue: function () {
    var self = this
    var value = _.reduce(self.stocks(), function(sum,stock) {
      return sum + (stock.shares * stock.open)
    }, 0.0)
    //console.log('Calculated value',value)
    return value
  },

  deltaAbsolute: function () {
    var self = this;
    return (self.currentValue() - self.prevValue())
  },

  deltaRelative: function () {
    var self = this;
    var prev = self.prevValue()
    return prev ? self.deltaAbsolute() / prev : 0
  }



});



if (Meteor.isServer) {


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
    
    ...
  ]
}

*/