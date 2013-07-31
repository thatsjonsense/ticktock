TIMER_INTERVAL = 15 * 1000;


_.extend(Meteor.Collection.prototype, {
  getOrCreate: function(selector) {
    // Find the element matching selector
    // If nothing is found, create that and return it
    var self = this;
    var match = self.findOne(selector);
    if (match) {
      return match._id;
    } else {
      return this.insert(selector);
    }
  }
});


// TODO: Where the heck can I put this?
function numberWithCommas(num) {
  var parts = num.toString().split(".");
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  return parts.join(".");
}

if(Meteor.isClient) {
  
  Session.setDefault('time_now',new Date());
  Meteor.setInterval(function () {
    Session.set('time_now',new Date());
  }, TIMER_INTERVAL);


  templateHelpers = {
    toPercent: function (num) {
      if (num == null || num == NaN) { return 'n/a'; }
      return (num * 100).toFixed(2) + '%';
    },
    toGain: function (num) {
      if (num == null || num == NaN) { return 'n/a'; }
      return (num > 0 ? '+' : '') + numberWithCommas(num.toFixed(2));
    },
    toDollars: function (num) {
      num = num || 0;
      return '$' + numberWithCommas(num.toFixed(2));
    },
    toMinAgo: function(timestamp) {
      var now = Session.get('time_now');
      return $.timeago(timestamp);
    }
  };

  _.each(templateHelpers, function(helper,name) {
    Handlebars.registerHelper(name,helper);
  });
}