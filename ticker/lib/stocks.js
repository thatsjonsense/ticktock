Stocks = new Meteor.Collection("stocks", {
  transform: function (doc) { return new Stock(doc); }
});

RANDOM_MODE = true
RANDOM_SWING = 0.001 // what % it will sway at a time
INTERVAL = 5000



// stock class
function Stock (doc) {
  _.extend(this, doc);
};

_.extend(Stock.prototype, {
  updatePrice: function () {
    // pulls latest price and start price from Yahoo API
    var self = this;
    
    Meteor.http.call("GET", "http://query.yahooapis.com/v1/public/yql?q=select%20Name%2CLastTradePriceOnly%2COpen%2CPreviousClose%20from%20yahoo.finance.quotes%20where%20symbol%20%3D%22" + self.symbol + "%22%0A%09%09&format=json&env=http%3A%2F%2Fdatatables.org%2Falltables.env",
      {params: {}},
      function (error, result) {
        if (result.statusCode === 200) {
          var price = result.data.query.results.quote.LastTradePriceOnly;
          var open = result.data.query.results.quote.Open;
          var previousClose = result.data.query.results.quote.PreviousClose;
          var name = result.data.query.results.quote.Name;
          //console.log('Updating stock', _this.symbol, price);
          
          // TODO:  REMOVE when markets are live!
          if(RANDOM_MODE) {
            var old_price = self.price || price

            var random = Math.random() * RANDOM_SWING * old_price;

            price = parseFloat(old_price) + (Math.random() < 0.5 ? random : -random);
          }

          // END REMOVE
         
          // TODO: is this the correct way to update yourself?
          Stocks.update({'symbol': self.symbol}, {$set: {'name': name, 'price': price, 'open': open, 'previousClose': previousClose}});
        } // TODO: error handling?
    });
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
  }

});


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
          console.log(fields.name, "just got added");
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