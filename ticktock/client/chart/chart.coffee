


Template.chart.quotes = ->
  Quotes.find({},
    sort:
      type: 1
      time: -1
    limit: 5
  )


MODE = 'stock'

Template.chart_circles_d3.rendered = ->

  Deps.autorun =>

    if MODE == 'stock'
      data = Stocks.find().fetch()
      template_row = Template.chart_circles_row_stock
    else
      data = Investors.find().fetch()
      template_row = Template.chart_circles_row


    # Make the chart
    bars = d3.select(@find('div'))
      .selectAll('.canvas')
      .data(data);

    scale = d3.scale.linear()
      .domain([-0.05,0.05])
      .range([-500,500])

    origin_x = 400;    

    addBars = (selection) ->
      selection.html (user) -> template_row(user)

    updateBars = (selection) ->

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
    updateBars bars.transition().duration(1000).ease('cubic-out')
    bars.exit().remove()
