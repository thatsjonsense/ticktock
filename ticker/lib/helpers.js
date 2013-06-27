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

_.extend(Number.prototype, {
	toPercent: function() {
		return (this * 100).toFixed(2) + '%'
	},
	toDollars: function() {
		return '$' + this.toFixed(2)
	},
	toGain: function() {
		return (this > 0 ? '+' : '') + this.toFixed(2)
	}

})