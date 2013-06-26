Users = new Meteor.Collection("users");
Stocks = new Meteor.Collection("stocks");

if (Meteor.isClient) {
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

}

if (Meteor.isServer) {
  Meteor.startup(function () {
    
    // User accounts
    if (Users.find().count() === 0) {

      var users = [
        {
          name: "Jon",
          portfolio: [
            // [symbol, shares, cost basis, date]
            ['GOOG',3,880.19],
            ['AMZN',10,265.30],
            ['CMG',3,375.86],
            ['LNKD',20,175.89]
          ]
        },
        {
          name: "Yuhki",
          portfolio: [
            ['FB',40,25.19],
            ['TSLA',10,57.2]
          ]
        },
        {
          name: "Lee",
          portfolio: [
            ['FRCOY',30,25.6],
            ['WSM',20,49.1],
            ['LNKD',10,161.7]
          ]
        },
        {
          name: "Asa",
          portfolio: [
            ['MSFT',50,27.5]
          ]
        },
        {
          name: "Richard",
          portfolio: []
        }
      ]

      _.each(users,function(user) {
        console.log('Adding user',user.name);

        var investments = []
        _.each(user.portfolio, function(investment) {
          investments.push({
            symbol: investment[0],
            shares: investment[1],
            cost_basis: investment[2]
          })
        })

        var user_id = Users.insert({name: user.name, investments: investments})

      })
    }

    // Stock values
    if (Stocks.find().count() === 0) {
      var stocks_mock = {
        "GOOG": 866.20,
        "AMZN": 272.09,
        "CMG": 358.96,
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

  /*
  Meteor.setInterval(function () {
    Stocks.update({'symbol': 'GOOG'},{$inc: {price: 5}})
    console.log('Updated price of GOOG to',Stocks.findOne({'symbol':'GOOG'}).price)
  },1000)
  */



}
