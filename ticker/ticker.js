Investors = new Meteor.Collection("investors");
Stocks = new Meteor.Collection("stocks");

if (Meteor.isClient) {
  Template.dashboard.investors = function () {
    return Investors.find({}, {sort: {name: 1}});
  };

  Template.investor.value = function () {
    var total = 0;
    _.each(this.portfolio,function (shares,symbol) {
      var price = Stocks.findOne({'symbol': symbol}).price
      total += (shares * price);
    })

    return total;
  }

  /*Template.hello.events({
    'click input' : function () {
      // template data, if any, is available in 'this'
      if (typeof console !== 'undefined')
        console.log("You pressed the button");
    }
  });*/
}

if (Meteor.isServer) {
  Meteor.startup(function () {
    
    // User accounts
    if (Investors.find().count() === 0) {
      var portfolios = {
        "Jon": {
          "GOOG": 3,
          "AMZN": 10,
          "NFLX": 10,
          "LNKD": 20
        },
        "Yuhki": {
          "FB": 40,
          "TSLA": 10,
        },
        "Asa": {
          "MSFT": 50
        },
        "Lee": {
          "FRCOY": 30,
          "WSM": 20,
          "LNKD": 10
        },
        "Richard": {

        }
      }

      _.each(portfolios,function (portfolio, name) {
        console.log('Adding user',name)
        var user_id = Investors.insert({'name': name,'portfolio': portfolio});
      });
    }

    // Stock values
    if (Stocks.find().count() === 0) {
      var stocks_mock = {
        "GOOG": 866.20,
        "AMZN": 272.09,
        "NFLX": 212.90,
        "LNKD": 176.87,
        "FB": 24.25,
        "TSLA": 102.40,
        "MSFT": 33.50,
        "FRCOY": 31.71,
        "WSM": 54.13
      }
    
      _.each(stocks_mock, function (price, symbol) {
        console.log('Adding stock',symbol)
        var stock_id = Stocks.insert({'symbol': symbol, 'price': price})
      })



    }

  });


  Meteor.setInterval(function () {
    Stocks.update({'symbol': 'GOOG'},{$inc: {price: 5}})
    console.log('Updated price of GOOG to',Stocks.findOne({'symbol':'GOOG'}).price)
  },1000)



}
