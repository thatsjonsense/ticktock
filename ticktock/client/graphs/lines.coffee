


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


  gainScale = d3.scale.linear()
    .domain([-.25,.25])
    .range(['1000','0'])

  Deps.autorun =>
    
    end = secondsBefore(minutesAgo(15),1)
    start = secondsBefore(end,10)

    stocks = Stocks.find().fetch()


    timeScale = d3.scale.linear()
      .domain([start,end])
      .range(['0','1000'])

    priceScale = d3.scale.linear()
      .domain([28,32])
      .range(['0','1000'])



    paths = svg.selectAll('path').data(stocks)
    labels = svg.selectAll('text').data(stocks)

    line = d3.svg.line()
      .x((d) -> 
        time = new Date(d[0])
        quote = d[1]
        timeScale time)      
      
      .y((d) -> 
        time = d[0]
        quote = d[1]
        price = parseFloat quote.price
        last_price = parseFloat quote.last_price
        gainRelative = (price - last_price) / last_price
        gainScale gainRelative)

      .interpolate('cardinal')

    # for each new stock...
    paths.enter()
      .append('path')
      .attr('stroke','white')
      .attr('stroke-width',2)
      .attr('fill','none')
      
    
    labels.enter()
      .append('text')
      .attr('font-size','20px')
      .attr('fill','white')
      

    labels
      .transition().duration(500)
      .attr('x','90%')
      .attr('y',(d) -> gainScale parseFloat d.gainRelative)
      .text((s) -> "#{s.symbol} #{templateHelpers.toPercent s.gainRelative}")

    paths
      .attr('d',(s) -> line(_.pairs s.history))
      .attr('transform',null)
    .transition().duration(1000)
      .ease('linear')
      .attr('transform',->"translate(#{timeScale secondsBefore(start,1)})")
    



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
  



  




