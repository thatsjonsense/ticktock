Meteor.startup(function () {
    
  // User accounts
  if (Users.find().count() === 0) {

    var users = [
      {
        name: "Jon",
        picture: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/c37.37.466.466/s160x160/1009774_10200809962025782_940179142_n.jpg",
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
        picture: "https://profile-a-pao.xx.fbcdn.net/hprofile-prn2/c44.41.507.507/s160x160/971644_10151484691048737_1780874470_n.jpg",
        portfolio: [
          ['FB',40,25.19],
          ['TSLA',10,57.2]
        ]
      },
      {
        name: "Lee",
        picture: "https://profile-a-pao.xx.fbcdn.net/hprofile-ash4/c136.22.280.280/s160x160/1002852_10200326613592871_1780888072_n.jpg",
        portfolio: [
          ['FRCOY',30,25.6],
          ['WSM',20,49.1],
          ['LNKD',10,161.7]
        ]
      },
      {
        name: "Asa",
        picture: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/c40.40.504.504/s160x160/228207_4012506921555_973224299_n.jpg",
        portfolio: [
          ['MSFT',50,27.5]
        ]
      },
      {
        name: "Richard",
        picture: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/c30.30.372.372/s160x160/224018_10150237819680140_5143660_n.jpg",
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
        picture: user.picture,
        investments: investments
      });

    });
  }
});