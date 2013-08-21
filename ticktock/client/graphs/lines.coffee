


colorBackground = ->

  red = "#db4437"
  green = "#0f9d58"

  Deps.autorun =>

    current_user = Investors.findOne({name: 'Jon'})

    if current_user?.up
     $('body').css('background-color',green)
    else if current_user?.down
      $('body').css('background-color',red)
    else
      # do nothing




Template.lines.rendered = ->

  colorBackground()
  $('body').css('height','100%')

  # setup
  svg = d3.select(@find '.lines')
    .append('svg')
    .attr('width','100%')
    .attr('height','100%')

  Deps.autorun =>
    
    # Data
    stocks = Stocks.find().fetch()

    # todo: use min/max here, and get min/max prices as well
    for s in stocks
      start = _.last(s.history)?.time
      end = _.first(s.history)?.time

    if not (start? and end?)
      return

    # Scales
    timeScale = d3.scale.linear()
      .domain([start,end])
      .range(['0','1000'])

    priceScale = d3.scale.linear()
      .domain([28,32])
      .range(['1000','0'])

    gainScale = d3.scale.linear()
      .domain([-.05,.05])
      .range(['1000','0'])


    print timeScale start
    print timeScale end


    # Binding
    paths = svg.selectAll('path').data(stocks)
    labels = svg.selectAll('text').data(stocks)

    # Line generator
    line = d3.svg.line()
      .x((q) -> 
        timeScale new Date(q.time))      
      
      .y((q) -> 
        price = parseFloat q.price
        last_price = parseFloat q.last_price
        gainRelative = (price - last_price) / last_price
        gainScale gainRelative)

      .interpolate('basis')

    # Paths
    paths.enter()
      .append('path')
      .attr('stroke','white')
      .attr('stroke-width',2)
      .attr('fill','none')
      
    paths
      .attr('d',(s) -> line(s.history))
      .attr('alt',(s) -> s.symbol)
      .attr('transform',null)
    .transition().duration(1000)
      .ease('linear')
      .attr('transform',->"translate(#{timeScale secondsBefore(start,1)})")
          
    # Labels
    labels.enter()
      .append('text')
      .attr('font-size','20px')
      .attr('fill','white')

    labels
      .transition().duration(500)
      .attr('x','90%')
      .attr('y',(d) -> gainScale parseFloat d.gainRelative)
      .text((s) -> "#{s.symbol} #{templateHelpers.toPercent s.gainRelative}")

    


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
  



  




