


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

  Deps.autorun =>
    
    # Data
    stocks = currentStocks()

    ###
    # todo: use min/max here, and get min/max prices as well
    for s in stocks
      start = _.last(s.history)?.time
      end = _.first(s.history)?.time
      minGain = _.min (q.gainRelative for q in s.history)
      maxGain = _.max (q.gainRelative for q in s.history)
    ###

    start = Infinity
    end = -Infinity
    minGain = Infinity
    maxGain = -Infinity

    for s in stocks
      for q in s.history
        
        q.time = new Date(q.time)
        q.price = parseFloat q.price
        q.last_price = parseFloat q.last_price
        q.gainRelative = (q.price - q.last_price) / q.last_price

        start = Math.min(start,q.time)
        end = Math.max(end,q.time)
        minGain = Math.min(minGain,q.gainRelative)
        maxGain = Math.max(maxGain,q.gainRelative)


    #start = new Date(start)
    end = new Date(end)
    start = hoursBefore(end,6.5)


    if not (start? and end?)
      return

    # Scales
    timeScale = d3.scale.linear()
      .domain([start,end])
      .range(['0','1000'])

    priceScale = d3.scale.linear()
      .domain([28,32])
      .range(['500','0'])

    gainScale = d3.scale.linear()
      .domain([minGain,maxGain])
      .range(['500','0'])

    # Binding
    paths = svg.selectAll('path').data(stocks)
    labels = svg.selectAll('text').data(stocks)

    # Line generator
    line = d3.svg.line()
      .x((q) -> 
        timeScale new Date(q.time))      
      
      .y((q) -> 
        gainScale q.gainRelative)

      .interpolate('basis')

    # Paths
    paths.enter()
      .append('path')
      .attr('stroke','white')
      .attr('fill','none')
      
    paths
      .attr('alt',(s) -> s.symbol)
      .attr('transform',null)
    .transition().duration(500)
      .attr('d',(s) -> line(s.history))
      .attr('stroke-width', (s,i) -> i+1)
      .ease('linear')
      .attr('transform',->"translate(#{timeScale secondsBefore(start,1)})")
          
    paths.exit().remove()


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

    labels.exit().remove()



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
  



  




