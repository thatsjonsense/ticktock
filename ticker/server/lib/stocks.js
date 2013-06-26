Stocks = new Meteor.Collection("stocks", {
  transform: function (doc) { return new Stock(doc); }
});

// stock class
function Stock (doc) {
  _.extend(this, doc);
};

_.extend(Stock.prototype, {
  updatePrice: function () {
    // pulls latest from Yahoo API
    var _this = this;
    Meteor.http.call("GET", "http://query.yahooapis.com/v1/public/yql?q=select%20LastTradePriceOnly%20from%20yahoo.finance.quotes%20where%20symbol%3D%22" + this.symbol + "%22%0A%09%09&format=json&env=http%3A%2F%2Fdatatables.org%2Falltables.env",
     {params: {}},
     function (error, result) {
       if (result.statusCode === 200) {
         var newPrice = result.data.query.results.quote.LastTradePriceOnly;
         console.log('Updating stock', _this.symbol, newPrice);
         // TODO: is this the correct way to update yourself?
         Stocks.update({'symbol': _this.symbol}, {$set: {'price': newPrice}});
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