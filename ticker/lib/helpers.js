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