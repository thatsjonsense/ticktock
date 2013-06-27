Alerts = new Meteor.Collection("alerts")

var stockObserver = Stocks.find({}).observe({
    changed: function (stock, old) {
      s = {}

      s.symbol = stock.symbol

      s.open = stock.open
      s.oldPrice = old.price
      s.newPrice = stock.price

      s.jump = s.newPrice - s.oldPrice
      s.jumpRelative = s.jump / s.oldPrice

      s.gain = s.newPrice - s.open
      s.gainRelative = s.gain / s.open


      _.each(rules,function(r){

        var condition = r.when
        var message = r.message
        
        // Check the condition
        _.each(s,function(value,property) {
          condition = condition.replace('[' + property + ']',value)
          message = message.replace('[' + property + ']',value)
        })

        var matched = eval(condition)
        
        console.log(condition,matched ? 'matched' : "didn't match")

        // Return the message
        if(matched) {
          console.log('Message',message)
        }

      })  
    }

})



rules = [
  {
    when: '[gainRelative] > .01',
    message: 'Whoa! [symbol] just went up 1%'
  },
  {
    when: '[gainRelative] < -.01',
    message: 'Ouch! [symbol] just fell 1%'
  }
]
