
// Keep portfolio value up to date

Meteor.setInterval(function () {

  userCursor = Users.find({});
  userCursor.forEach(function (user) {
    
    var total = 0;
    _.each(user.investments,function (i) {
      var stock = Stocks.findOne({'symbol': i.symbol})
      if (stock) {
        var price = stock.price
        total += (i.shares * price);
      }
    })

    Users.update(user._id, {$set: {value: total}})
  })

}, 5000)

// Todo: abstract this function to get all of a user's stocks