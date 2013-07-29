Stocks = new Meteor.Collection("stocks", {
  transform: function (doc) { return new Stock(doc); }
});

RANDOM_MODE = true
RANDOM_SWING = 0.001 // what % it will sway at a time
INTERVAL = 1000



// stock class
function Stock (doc) {
  _.extend(this, doc);
};

_.extend(Stock.prototype, {
  updatePrice: function () {
    this.updatePriceRandom();
  },

  updatePriceRandom: function () {
    var old_price = parseFloat(this.price);
    var delta = randomBetween(-1, 1) * RANDOM_SWING * old_price;
    var new_price = delta + old_price;
    this.set({
      price: new_price
    });
    
  },

  updatePriceLive: function () {
    var self = this;
    Meteor.http.call(
      "GET",
      "http://query.yahooapis.com/v1/public/yql?q=select%20Name%2CLastTradePriceOnly%2COpen%2CPreviousClose%20from%20yahoo.finance.quotes%20where%20symbol%20%3D%22" + this.symbol + "%22%0A%09%09&format=json&env=http%3A%2F%2Fdatatables.org%2Falltables.env",
      {params: {}},
      function (error, result) {
        if(result.statusCode != 200) {
          //todo: handle error better
          return null;
        } else {
          self.set({
            price: result.data.query.results.quote.LastTradePriceOnly,
            open: result.data.query.results.quote.Open,
            previousClose: result.data.query.results.quote.PreviousClose,
            name: result.data.query.results.quote.Name
          });
        }
      }
    );
  },

  updatePriceHistorical: function(time) {

  },

  deltaAbsolute: function () {
    var self = this;
    return (self.price - self.previousClose)
  },

  deltaRelative: function () {
    var self = this;
    return self.previousClose ? self.deltaAbsolute() / self.previousClose : 0
  },
  
  owners: function () {
    var self = this;
    return Users.find({investments: {$elemMatch: {symbol: self.symbol}}}).fetch();
  },

  // Database helper functions
  update: function (modifier) {
    return Stocks.update(this._id, modifier);
  },

  set: function (keyval) {
    return this.update({$set: keyval});
  }

});

// Helper functions

function randomBetween(lower,upper) {
  return Math.random() * (upper - lower) + lower
}

// Startup


if (Meteor.isServer) {
  Meteor.startup(function(){
    // We only should poll prices for stocks that users care about


    // Keep stock prices up to date
    Meteor.setInterval(function () {
      stockCursor = Stocks.find({});
      stockCursor.forEach(function (stock) {
        stock.updatePrice();
      });
    }, INTERVAL);

    // Add stocks whenever we see a user added or portfolio change
    var userObserver = Users.find({}).observeChanges({
      added: function (id, fields) {
        if (fields.investments) {
          _.each(fields.investments,function (i) {
            Stocks.getOrCreate({symbol: i.symbol});
          });
        }
      },
      
      changed: function (id,fields) {
        if (fields.investments) {
          console.log(id,'changed investments',fields.investments)
          _.each(fields.investments,function (i) {
            Stocks.getOrCreate({symbol: i.symbol});
          });
        }        
      }
    }) // observer

    // TODO: remove stocks




  }) // startup

} // isServer