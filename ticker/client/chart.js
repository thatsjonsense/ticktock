// Let's start with a bar chart of portfolio values


// Whenever the chart is rendered...
Template.chart.rendered = function () {
	var self = this;
	self.node = self.find("svg");

	// Rerun this function anytime dependencies change
	if (!self.autorunning) {
		self.autorunning = Deps.autorun(function() {
			var users = Users.find({}).fetch();
      var svg = d3.select(self.node);
      var bars = svg.selectAll('rect').data(users);

      var updateBars = function(selection) {
        selection
          .attr("width",function(user) {return (user.currentValue % 100) * 10})
          .attr("height",10)
          .attr("y", function(d,i) {return i * 11})
      }


      updateBars(bars.enter().append('rect'));
      updateBars(bars.transition().duration(250).ease('cubic-out'));
      bars.exit().transition().duration(250).attr('width',0).remove();
        


		})
	}
}

/*
// Hack to keep chart live updating. Need a better system
Template.chart.users = function () {
	return Users.find({}).fetch()
}
*/