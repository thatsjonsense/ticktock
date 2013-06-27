Template.newsfeed.entries = function () {
  return Alerts.find({},{
    sort: {timestamp: -1},
    limit: 10
  })
}