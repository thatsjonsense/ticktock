Alerts = new Meteor.Collection("alerts")
/*
alert = {
  type: 'big_gain',
  data: {symbol: GOOG, oldPrice: 800, newPrice: 900, ...},
  about: stock symbol, or user, or whatever
  timestamp: 834920489032
}
*/

//todo: implement per-alert frequency (eg no more than X times in the last Y hours)
FREQUENCY = 1 * 60 * 1000 // Time, in milliseconds * seconds * minutes, to wait before redoing a notification about the same thing

rules = {
  'big_gain': function(s) {return s.gainRelative > .03},
  'big_loss': function(s) {return s.gainRelative < -.03}
}

if (Meteor.isServer) {
  Meteor.startup(function(){

    var stockObserver = Stocks.find({}).observe({
      changed: function (stock, old) {
        s = {}

        s.symbol = stock.symbol

        s.prevPrice = stock.previousClose
        s.oldPrice = old.price
        s.newPrice = stock.price

        s.jump = s.newPrice - s.oldPrice
        s.jumpRelative = s.jump / s.oldPrice

        s.gain = s.newPrice - s.prevPrice
        s.gainRelative = s.gain / s.prevPrice


        _.each(rules,function(condition,name){
          if (condition(s)) {
            var time = new Date().getTime()


            // Check if we've already done this notification
            var num_past_alerts = Alerts.find({
              about: s.symbol,
              type: name,
              timestamp: {$gt: time - FREQUENCY}
            }).count()

            if (num_past_alerts) {
              //console.log('suppressing repeat alert',name,'about',s.symbol)
            } else {
              var record = {
                about: s.symbol,
                type: name,
                timestamp: time,
                data: s
              }
              var a = Alerts.insert(record)
              //console.log(Alerts.findOne(a))
            }


          }
        })  
      }
    })  


  })
}