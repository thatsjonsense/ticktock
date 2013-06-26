Stocks = new Meteor.Collection("stocks", {
  transform: function (doc) { return new Stock(doc); }
});

// stock class
function Stock (doc) {
  _.extend(this, doc);
};

_.extend(Stock.prototype, {
  updatePrice: function () {
    // pulls latest price and start price from Yahoo API
    var _this = this;
    
    
    Meteor.http.call("GET", "http://query.yahooapis.com/v1/public/yql?q=select%20LastTradePriceOnly%2COpen%2CPreviousClose%20from%20yahoo.finance.quotes%20where%20symbol%20%3D%22" + this.symbol + "%22%0A%09%09&format=json&env=http%3A%2F%2Fdatatables.org%2Falltables.env",
     {params: {}},
     function (error, result) {
       if (result.statusCode === 200) {
         var price = result.data.query.results.quote.LastTradePriceOnly;
         var open = result.data.query.results.quote.Open;
         var previousClose = result.data.query.results.quote.PreviousClose;
         //console.log('Updating stock', _this.symbol, price);
         // TODO: is this the correct way to update yourself?
         Stocks.update({'symbol': _this.symbol}, {$set: {'price': price, 'open': open, 'previousClose': previousClose}});
         console.log('Updated:', _this.symbol, 'price:' , _this.price, 'open:', _this.open, 'previousClose:', _this.previousClose);
       } // TODO: error handling?
    });
  }
});

// updates all stocks every 15 seconds
Meteor.setInterval(function () {
  stockCursor = Stocks.find({});
  stockCursor.forEach(function (stock) {
    stock.updatePrice();
  });
}, 15000);