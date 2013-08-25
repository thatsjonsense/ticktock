


colorBackground = ->

  red = "#db4437"
  green = "#0f9d58"

  Deps.autorun =>

    current_user = Investors.findOne({name: 'Jon'})

    if current_user?.up
     $('body').css('background-color',green)
    else
      $('body').css('background-color',red)




Template.lines.rendered = ->

  colorBackground()
  $('body').css('height','100%')

  # setup
  svg = d3.select(@find '.lines')
    .append('svg')
    .attr('width','100%')
    .attr('height','100%')

  div = d3.select(@find '.lines')

  x_axis = svg.append('line')

  Deps.autorun =>
    
    # Get data, or wait until it's available
    stocks = currentStocks()
    i = Investors.findOne Session.get('viewingUserId')
    quotes = _.flatten (s.history() for s in stocks)
    
    if i?
      lineData = _.union stocks, [i]
    else
      lineData = stocks


    # Cleanup and buildup
    lines = svg.selectAll('path').data(lineData, (d) -> d._id)
    lines.enter()
        .append('path')
        .attr('fill','')
        .attr('stroke','') # use css    
    lines.exit().remove()



    labels = div.selectAll('.lineLabel').data(lineData, (s) -> s.symbol)
    labels.enter()
      .append('div')
      .classed('lineLabel',true)
    labels.exit().remove()

    if quotes.length == 0 then return

    # Scales
    x = d3.scale.linear()
      .domain(d3.extent quotes, (q) -> q.time)
      .range(['0','1000'])

    y = d3.scale.linear()
      .domain(d3.extent quotes, (q) -> q.gainRelative)
      .range(['500','10'])

    z = d3.scale.linear()
      .domain([0,1])
      .range([1,10])

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
        if s.symbol and i
          z i.pie[s.symbol]
        else if s.symbol
          z 0
        else
          z 1
      )
      .classed('stock', (d) -> d.symbol?)
      .classed('investor', (d) -> d.investor?)
      
    # Labels

    labels
      .html((s) -> 
        """<span class='symbol'>#{s.symbol ? s.name}</span>
          <span class='gain'>#{templateHelpers.toPercent s.gainRelative}</span>""")
      .style('left','90%')
      .style('top',(s) -> y(s.gainRelative) + 'px')

    



Template.slopes.rendered = ->

  colorBackground()
  $('body').css('height','100%')

  # setup
  svg = d3.select(@find '.lines')
    .append('svg')
    .attr('width','100%')
    .attr('height','100%')


  gainScale = d3.scale.linear()
    .domain([-.1,.1])
    .range(['0%','100%'])

  priceScale = d3.scale.linear()
    .domain([0,1000])
    .range(['0%','100%'])

  timeScale = d3.scale.linear()
    .domain([0,1])
    .range(['0%','90%'])


  # bind data
  stocksMock = [
    {symbol: 'AAPL', prices: [50, 40]},
    {symbol: 'MSFT', prices: [30, 35]}
  ]

  Deps.autorun =>
    stocks = Stocks.find().fetch()

    lines = svg.selectAll('line').data(stocks)
    labels = svg.selectAll('text').data(stocks)

    # for each new stock...
    lines.enter()
      .append('line')
      .attr('stroke','white')
      .attr('stroke-width',2)
    
    labels.enter()
      .append('text')
      .text((d) -> d.symbol)
      .attr('font-size','20px')
      .attr('fill','white')
      

    labels
      .transition().duration(500)
      .attr('x',timeScale 1)
      .attr('y',(d) -> gainScale parseFloat d.gainRelative)

    lines
      .transition().duration(500)
      .attr('x1',timeScale 0)
      .attr('x2',timeScale 1)
      .attr('y1',(d) -> gainScale 0)
      .attr('y2', (d) -> gainScale parseFloat d.gainRelative)




  # other crap
  

  # Live ticking
  ###
  paths
    .attr('transform',null)
  .transition().duration(1000).ease('linear')
    .attr('transform',->"translate(#{timeScale secondsBefore(start,1)})")
  ###

  




