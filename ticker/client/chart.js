// Let's start with a bar chart of portfolio values


Template.chart_divs.rendered = function() {
  var self = this;

  if (!self.autorunning) {
    self.autorunning = Deps.autorun(function() {
      
      // Dependencies
      var users = Users.find({},{sort: {currentValue: -1}}).fetch();
      

      // Make the chart
      var bars = d3.select(self.find('.chartDivs'))
        .selectAll('div')
        .data(users);

      var updateBars = function(selection) {
        selection
          .style("width",function(user) {return user.deltaRelative()* 10000 + 'px'})
          .attr("class","bar")
          .text(function(user) {return user.name})
      }

      updateBars(bars.enter().append('div'));
      updateBars(bars.transition().duration(250).ease('cubic-out'));
      bars.exit().transition().duration(250).attr('width',0).remove();
        
    });
  } 

}

Template.chart_bar.rendered = function () {
  var self = this;

  if (!self.autorunning) {
    self.autorunning = Deps.autorun(function() {
      
      // Dependencies
      var users = Users.find({}).fetch();
      

      // Make the chart
      var svg = d3.select(self.find('svg'));
      var bars = svg.select('.bars').selectAll('rect').data(users);

      // Todo: put this into the template. CSS would be even better but how?
      var HEIGHT = 100;
      var MARGIN = 1;

      var updateBars = function(selection) {
        selection
          .attr("width",function(user) {return (user.currentValue % 100) * 10})
          .attr("height",HEIGHT)
          .attr("y", function(d,i) {return i * (HEIGHT + MARGIN)})
          .attr("class","bar")
      }

      updateBars(bars.enter().append('rect'));
      updateBars(bars.transition().duration(250).ease('cubic-out'));
      bars.exit().transition().duration(250).attr('width',0).remove();
        
    });
  } 
}

/*

TODO:

Make it less ugly
Flash red/green depending on up or down since last tick
Label with names and values


Eventually: line graph of one person's portfolio, scrolling. Then everyone's in different colors.


*/