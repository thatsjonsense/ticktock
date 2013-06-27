Template.newsfeed.entries = function () {
  return Alerts.find({},{
    sort: {timestamp: -1},
    limit: 10
  })
}

Template.newsfeed_entry.message = function () {
  /*
  return Meteor.render(function(){
    return Template.alert_big_gain(this.data)
  })*/
  return Template['alert_' + this.type](this.data)

  
}