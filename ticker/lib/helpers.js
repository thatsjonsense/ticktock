// random helper functions

_.extend(Meteor.Collection.prototype, {
	getOrCreate: function(selector) {
		// Find the element matching selector
		// If nothing is found, create that and return it
		var self = this;
		var match = self.findOne(selector);
		if (match) {
			return match._id
		} else {
			return this.insert(selector)
		}
	}




})

// TODO: Where the heck can I put this?
function numberWithCommas(num) {
  var parts = num.toString().split(".");
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  return parts.join(".");
}


if(Meteor.isClient) {
	
	templateHelpers = {
		toPercent: function(num) {
			if (num == null || num == NaN) {return 'n/a'}
			return (num * 100).toFixed(1) + '%'
		},
		toGain: function(num) {
			if (num == null || num == NaN) {return 'n/a'}
			return (num > 0 ? '+' : '') + numberWithCommas(num.toFixed(2));
		},
		toDollars: function(num) {
			if (num == null) {return 'n/a'}
			return '$' + numberWithCommas(num.toFixed(2));
		}
	};

	_.each(templateHelpers, function(helper,name) {
		Handlebars.registerHelper(name,helper)
	});
	



}