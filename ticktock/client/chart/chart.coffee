


Template.chart.quotes = ->
  Quotes.find({},
    sort:
      type: 1
      time: -1
    limit: 5
  )

Template.chart_circles_d3.rendered = ->

  Deps.autorun =>

    @investors = Investors.find().fetch()
    
    # Keep latest_quote up to date, without retriggering autorun
    Deps.nonreactive =>
      if @timer then Meteor.clearInterval(@timer)
      @timer = Meteor.setIntervalInstant(=>
        for investor in @investors
          if investor? # weirdly, this is undefined sometimes
            q = investor.latestQuote()
            investor.latest_quote.set q
      ,1000)

    # Make the chart
    bars = d3.select(@find('div'))
      .selectAll('.canvas')
      .data(@investors);

    scale = d3.scale.linear()
      .domain([-0.05,0.05])
      .range([-500,500])

    origin_x = 400;    

    addBars = (selection) ->
      selection.html (user) -> Template.chart_circles_row(user)

    updateBars = (selection) ->

      y = (user) -> scale(user.latest_quote.get()?.gainRelative or 0)

      selection.select('.bar')
        .style('width', (user) -> Math.abs(y(user)) + 'px')
        .style('left', (user) ->
          if user.latest_quote.get()?.up
            origin_x + 'px'
          else
            origin_x + y(user) + 'px' # position right from center
        )

      selection.select('.cap')
        .style('left', (user) -> origin_x + y(user) + 'px')

      selection.select('.gain')
        .style('color', (user) -> 
          if user.latest_quote.get().up
            '#248d00'
          else
            '#cd0000'
        )
        .text (user) -> templateHelpers.toPercent user.latest_quote.get()?.gainRelative



    addBars bars.enter().append('div')
    updateBars bars.transition().duration(1000).ease('cubic-out')
    bars.exit().remove()
