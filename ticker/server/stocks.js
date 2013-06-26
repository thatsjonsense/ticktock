Meteor.setInterval(function () {
  stockCursor = Stocks.find({});
  stockCursor.forEach(function (stock) {
    // grab latest from Yahoo API
    Meteor.http.call("GET", "http://query.yahooapis.com/v1/public/yql?q=select%20LastTradePriceOnly%20from%20yahoo.finance.quotes%20where%20symbol%3D%22" + stock.symbol + "%22%0A%09%09&format=json&env=http%3A%2F%2Fdatatables.org%2Falltables.env",
                     {params: {}},
                     function (error, result) {
                       if (result.statusCode === 200) {
                         var new_price = result.data.query.results.quote.LastTradePriceOnly;
                         console.log('Updating stock', stock.symbol, new_price);
                         Stocks.update({'symbol': stock.symbol}, {$set: {'price': new_price}});
                       } // TODO: error handling?
                  });
  
  
  
  });
}, 15000);