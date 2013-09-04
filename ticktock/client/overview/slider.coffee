LATEST = Stock.tradingClose TODAY
EARLIEST = Stock.tradingOpen TODAY

Template.time_slider.rendered = ->
  
  scale = d3.time.scale()
    .domain([EARLIEST,LATEST])
    .range([0,100])

  start = scale Session.get('clock_start')
  end = scale Session.get('clock_end')
  now = scale Session.get('clock_now')

  slider = $("#timeSlider").slider
    #range: true
    min: 0
    max: 100
    #values: [start, end]
    value: now

  onSlide = (event, ui) ->
    #Session.set('clock_start', scale.invert ui.values[0])
    #Session.set('clock_end', scale.invert ui.values[1])
    Session.set('clock_now', scale.invert ui.value)

  #slider.on "slide", _.throttle(onSlide,1000,{leading: false})
  slider.on "slide", onSlide


Template.time_slider.events
  'click .play': ->

    tick = =>
      time = Session.get('clock_now')
      time = minutesAfter(time,15)
      
      if time >= Session.get('clock_end')
        Meteor.clearInterval @handle
        return

      Session.set('clock_now',time)

    Session.set('clock_now',Session.get('clock_start'))
    @handle = Meteor.setInterval tick, 1000   


  'click .today': ->
    today = Stock.lastTradingDay()
    Session.set('clock_start', Stock.tradingOpen today)
    Session.set('clock_end', Stock.tradingClose today)

  'click .yesterday': ->
    today = Stock.lastTradingDay()
    yesterday = Stock.lastTradingDay daysBefore(today, 1)
    Session.set('clock_start', Stock.tradingOpen yesterday)
    Session.set('clock_end', Stock.tradingClose yesterday)

  'click .both': ->
    today = Stock.lastTradingDay()
    yesterday = Stock.lastTradingDay daysBefore(today, 1)
    Session.set('clock_start', Stock.tradingOpen yesterday)
    Session.set('clock_end', Stock.tradingClose today)

Template.time_slider.start = ->
  Session.get('clock_start')

Template.time_slider.end = ->
  Session.get('clock_end')
