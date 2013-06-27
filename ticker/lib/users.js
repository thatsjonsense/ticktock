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

  getCurrentValue: function () {
    var self = this
    var value = _.reduce(self.stocks(), function(sum,stock) {
      return sum + (stock.shares * stock.price)
    }, 0.0)
    //console.log('Calculated value',value)
    return value
  },

  getPrevValue: function () {
    var self = this
    var value = _.reduce(self.stocks(), function(sum,stock) {
      return sum + (stock.shares * stock.open)
    }, 0.0)
    //console.log('Calculated value',value)
    return value
  },

  deltaAbsolute: function () {
    var self = this;
    return self.prevValue ? self.currentValue - self.prevValue : 0;
  },

  deltaRelative: function () {
    var self = this;
    return self.prevValue ? self.deltaAbsolute() / self.prevValue : 0
  },




  // Database helper functions
  update: function (modifier) {
    var self = this;
    return Users.update(self._id, modifier)
  },

  set: function (keyval) {
    var self = this;
    return self.update({$set: keyval})
  }

});



if (Meteor.isServer) {
  Meteor.startup(function () {


  var stockObserver = Stocks.find({}).observe({
    changed: function (stock, oldStock) {
      var owners = stock.owners();
      _.each(owners,function(user) {
        user.set({
          currentValue: user.getCurrentValue(),
          prevValue: user.getPrevValue()
        })
      })
    }

      
    })

  })
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