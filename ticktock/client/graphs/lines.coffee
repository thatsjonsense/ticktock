
historyLines = (canvas,stocks,investor) ->

  data = stocks.slice(0)
  data.push(investor) if investor?

  # Setup and cleanup
  root = d3.select(canvas)
  svg = root.select('svg')
  x_axis = svg.select('.xAxis')

  lines = svg.selectAll('path').data(data, (d) -> d._id)
  lines.enter()
    .append('path')
    .attr('fill','')
    .attr('stroke','') # use css
  lines.exit()
    .remove()

  quotes = _.flatten (s.history() for s in stocks)
  if quotes.length == 0 then return

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
    .attr('stroke','white')
    .attr('y1', y 0)
    .attr('y2', y 0)
    .attr('x1', x.range()[0])
    .attr('x2', x.range()[1])

  # Lines
  makeLine = d3.svg.line()
    .x((q) -> x q.time)  
    .y((q) -> y q.gainRelative)
    .interpolate('basis')
    
  lines#.transition().duration(100).ease('linear')
    .attr('d',(s) -> makeLine s.history())
    .attr('stroke-width', (s) ->  
      if s.symbol and investor?
        z investor.pie[s.symbol]
      else if s.symbol
        z 0
      else
        z 1
    )
    .attr('data-symbol',(d) -> d.symbol)
    .attr('data-type',(d) -> if d.symbol? then 'stock' else 'investor')


priceMovers = (canvas, stocks) ->
  root = d3.select(canvas)
  data = stocks.slice(0)

  tiles = root.selectAll('.moverTile').data(data, (s) -> s._id)
  tiles.enter()
    .append('div')
    .attr('class','moverTile')
    .html((s) -> Template.moverTile s)
  tiles.exit()
    .remove()

  tiles.order()

  tiles.select('.symbol')
    .text((s) -> s.symbol)

  tiles.select('.gain')
    .text((s) -> templateHelpers.toPercent s.gainRelative)

  tiles.on 'mouseenter', (d) ->
    line = $("[data-symbol=#{d.symbol}]")
    line.attr('data-active',true)

  tiles.on 'mouseleave', (d) ->
    line = $("[data-symbol=#{d.symbol}]")
    line.attr('data-active',false)



Template.lines.rendered = ->
  $('body').css('height','100%')  

  lines = @find '.lines'
  movers = @find '.movers'

  Deps.autorun ->
    stocks = _.sortBy currentStocks(), (s) -> -s.gainRelative
    print stocks
    investor = Investors.findOne Session.get('viewingUserId')

    historyLines lines, stocks, investor
    priceMovers movers, stocks

    if investor?.up
      $('.left').attr('data-overall','up')
    else
      $('.left').attr('data-overall','down')

  




