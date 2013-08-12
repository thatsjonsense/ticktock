
dates =
      mon: new Date(1375255370000)
      tue: new Date(1375255370001)
      wed: new Date(1375255370002)
      thu: new Date(1375255370003)
      fri: new Date(1375255370004)

@MOCK_DATES = dates

investors = [
  {
    name: "Jon"
    picture: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/c37.37.466.466/s160x160/1009774_10200809962025782_940179142_n.jpg"
    trades: [
      {type:'buy', symbol: 'GOOG', shares: 3, cost: 880.19, date: dates.mon}
      {type:'buy', symbol: 'AMZN', shares: 10, cost: 265.30, date: dates.tue}
      {type:'buy', symbol: 'CMG', shares: 3, cost: 375.86, date: dates.wed}
      {type:'buy', symbol: 'LNKD', shares: 20, cost: 175.89, date: dates.thu}
      {type:'buy', symbol: 'MSFT', shares: 10, cost: 33.25, date: dates.mon}
      {type:'buy', symbol: 'MSFT', shares: 5, cost: 31.0, date: dates.tue}
      {type:'sell', symbol: 'MSFT', shares: 7, cost: 36.5, date: dates.wed}
    ]
  },
  {
    name: "Yuhki"
    picture: "https://profile-a-pao.xx.fbcdn.net/hprofile-prn2/c44.41.507.507/s160x160/971644_10151484691048737_1780874470_n.jpg"
    trades: [
      {type:'buy', symbol: 'FB', shares: 40, cost: 25.19, date: dates.mon}
      {type:'buy', symbol: 'TSLA', shares: 10, cost: 57.2, date: dates.wed}
      {type:'sell', symbol: 'TSLA', shares: 10, cost: 128.6, date: dates.fri}
    ]
  },
  {
    name: "Lee"
    picture: "https://profile-a-pao.xx.fbcdn.net/hprofile-ash4/c136.22.280.280/s160x160/1002852_10200326613592871_1780888072_n.jpg"
    trades: [
      {type:'buy', symbol: 'FRCOY', shares: 30, cost: 25.6, date: dates.mon}
      {type:'buy', symbol: 'WSM', shares: 20, cost: 49.1, date: dates.wed}
      {type:'buy', symbol: 'LNKD', shares: 10, cost: 161.7, date: dates.fri}
    ]
  },
  {
    name: "Asa"
    picture: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/c40.40.504.504/s160x160/228207_4012506921555_973224299_n.jpg"
    trades: [
      {type:'buy', symbol: 'MSFT', shares: 50, cost: 27.5, date: dates.tue}
      {type:'sell', symbol: 'MSFT', shares: 50, cost: 32.5, date: dates.fri}
    ]
  },
  {
    name: "Richard"
    picture: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/c30.30.372.372/s160x160/224018_10150237819680140_5143660_n.jpg"
    trades: []
  }
]

Meteor.startup ->
  if Investors.find().count() == 0
    for investor in investors
      debug("Added #{investor.name} to database")
      Investors.insert(investor)