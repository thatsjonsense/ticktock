


Template.chart.title = ->
  if Session.get('chartMode') == 'investors'
    return "All Investors"
  else if Session.get('chartMode') == 'stocks'
    viewing_user = Investors.findOne Session.get('viewingUserId')
    if viewing_user
      return viewing_user.name + "'s Portfolio"
    else
      return "All Stocks"


makeChart = (root,data) ->

  # Make the chart
  bars = d3.select(root)
    .selectAll('.chartRow')
    .data(data);

  scale = d3.scale.linear()
    .domain([-0.05,0.05])
    .range([-500,500])

  origin_x = 400;    

  addBars = (selection) ->
    selection.html (user) -> Template.chart_circles_row(user)

  updateBars = (selection) ->
    if Session.get('chartMode') == 'stocks'
      selection.select('.name a')
        .text((d) -> d.symbol)
        .attr('href',(d) -> '')

      selection.select('.head')
        .style('background-image',(d) -> "url('http://www.bing.com/th?q=#{d.symbol}%20stock%20logo&h=80&w=80')")

    if Session.get('chartMode') == 'investors'
      selection.select('.name a')
        .text((d) -> d.name)
        .attr('href', (d) -> "/chart/portfolio/#{d._id}")

      selection.select('.head')
        .style('background-image',(d) -> "url('#{d.picture}')")

  smoothUpdateBars = (selection) ->

    y = (user) -> scale(user.gainRelative or 0)

    selection.select('.bar')
      .style('width', (user) -> Math.abs(y(user)) + 'px')
      .style('left', (user) ->
        if user.up
          origin_x + 'px'
        else
          origin_x + y(user) + 'px' # position right from center
      )

    selection.select('.cap')
      .style('left', (user) -> origin_x + y(user) + 'px')

    selection.select('.gain')
      .style('color', (user) -> 
        if user.up
          '#248d00'
        else
          '#cd0000'
      )
      .text (user) -> templateHelpers.toPercent user.gainRelative

  addBars bars.enter().append('div')
  smoothUpdateBars bars.transition().duration(1000).ease('cubic-out')
  updateBars bars
  bars.exit().remove()



Template.chart_circles_d3.rendered = ->

  Deps.autorun =>

    if Session.get('chartMode') == 'stocks'
      data = currentStocks()
    else
      data = Investors.find().fetch()

    makeChart(@find('.chartCircles'),data)
