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
      //updateBars(bars.transition().duration(250).ease('cubic-out'));
      bars.exit().transition().duration(250).attr('width',0).remove();
        
    });
  } 
}

Template.chart_circles_d3.rendered = function () {

  var self = this;

  if (!self.autorunning) {
    self.autorunning = Deps.autorun(function() {
      
      // Dependencies
      var users = Users.find({},{sort: {currentValue: -1}}).fetch();
      
      // Make the chart
      var bars = d3.select(self.find('div'))
        .selectAll('.canvas')
        .data(users);

      var scale = d3.scale.linear()
        .domain([-0.1,0.1])
        .range([-500,500])

      var origin_x = 400;



      var addBars = function(selection) {

        selection.html(function (user) {
          return Template.chart_circles_row(user)
        });
        updateBars(selection);
      
      }

      var updateBars = function(selection) {
        //var origin_x = selection.select('.canvas').attr('x') 

        // Position that all these bars are trying to hit
        function y(user) {
          //console.log(user.deltaRelative(),scale(user.deltaRelative()))
          return scale(user.deltaRelative())

        }




        selection.select('.bar')
          .style('width',function(user) {return Math.abs(y(user)) + 'px'})
          .style('left', function(user) {
            if (user.isGaining()) {
              return origin_x + 'px';
            } else {
              return origin_x + y(user) + 'px';
            }
          })

        selection.select('.cap')
          .style('left',function (user) {return origin_x + y(user) + 'px'})

        selection.select('.gain')
          .style('color',function (user) {return user.isGaining() ? '#248d00' : '#cd0000'})
          //.classed('up', function (user) {return user.isGaining()})
          //.classed('down', function (user) {return !user.isGaining()})
          .text(function (user) {return templateHelpers.toPercent(user.deltaRelative())})
      }

      addBars(bars.enter().append('div'));
      updateBars(bars.transition().duration(500).ease('cubic-out'));
      bars.exit().remove();
        
    });
  } 

}

// non-D3 mode

/*
Template.chart_circles.users = function () {
  return Users.find({}).fetch();
}

Template.chart_circles_row.updown = function () {
  return this.deltaAbsolute() >= 0 ? "up" : "down";
}
*/

// d3 mode



/*

TODO:

Make it less ugly
Flash red/green depending on up or down since last tick
Label with names and values


Eventually: line graph of one person's portfolio, scrolling. Then everyone's in different colors.


*/