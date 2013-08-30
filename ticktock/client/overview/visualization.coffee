
historyLines = (canvas,stocks,investor) ->

  data = stocks.slice(0)
  data.push(investor) if investor?

  # Setup and cleanup
  root = d3.select(canvas)
  svg = root.select('svg')
  x_axis = svg.select('.xAxis')

  lines = svg.selectAll('path').data(data, (d) -> 
    d.symbol ? 'investor'
  )
  lines.enter()
    .append('path')
    .attr('fill','')
    .attr('stroke','') # use css
  lines.exit()
    .remove()

  loading = not Session.get('history_ready')
  quotes = _.flatten (s.history() for s in stocks)
  if loading or quotes.length == 0 then return

  # Scales
  w = $(canvas).width()
  h = $(canvas).height()
  pad = 10

  x = d3.scale.linear()
    .domain(d3.extent quotes, (q) -> q.time)
    .range([pad,w-pad])

  y = d3.scale.linear()
    .domain(d3.extent quotes, (q) -> q.gainRelative)
    .range([h-pad,pad])

  z = d3.scale.linear()
    .domain([0,1])
    .range([2,10])

  x_axis
    .attr('x1', x.range()[0])
    .attr('x2', x.range()[1])
    .attr('stroke','white')
  .transition().duration(500)
    .attr('y1', y 0)
    .attr('y2', y 0)


  # Lines
  makeLine = d3.svg.line()
    .x((q) -> x q.time)  
    .y((q) -> y q.gainRelative)
    .interpolate('basis-open')
    
  lines.transition().duration(500).ease('linear')
    .attr('d',(s) -> 
      makeLine s.history())
    .attr('stroke-width', (s) ->  
      if s.symbol and investor?.pie?[s.symbol]
        z investor.pie[s.symbol]
      else if s.symbol
        z 0
      else
        z 1
    )
    .attr('data-symbol',(d) -> d.symbol)
    .attr('data-type',(d) -> if d.symbol? then 'stock' else 'investor')


Template.visualization_lines.rendered = ->
  $('body').css('height','100%')  

  lines = @find '.lines'

  Deps.autorun ->
    stocks = _.sortBy currentStocks(), (s) -> -s.gainRelative
    investor = Investors.findOne Session.get('viewingUserId')

    historyLines lines, stocks, investor

    if investor?.up
      $('.visualization, .portfolio').attr('data-overall','up')
    else
      $('.visualization, .portfolio').attr('data-overall','down')

Template.visualization_lines.loading = ->
  not Session.get('history_ready')


