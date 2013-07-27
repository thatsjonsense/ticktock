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
    ];

    _.each(users, function (user) {
      var investments = [];
      _.each(user.portfolio, function (investment) {
        investments.push({
          symbol: investment[0],
          shares: investment[1],
          cost_basis: investment[2]
        });
      });

      var user_id = Users.insert({
        name: user.name, 
        investments: investments
      });

    });
  }
});