LATEST = now()
EARLIEST = daysAgo(2)

today = Stock.lastTradingDay()

Session.setDefault('clock_end', Stock.tradingClose today)
Session.setDefault('clock_start', Stock.tradingOpen today)


# Stabilizer

clockStable = ->
  Session.set('clock_start_stable', Session.get('clock_start'))
  Session.set('clock_end_stable', Session.get('clock_end'))

Meteor.setIntervalInstant _.throttle(clockStable,1000), 100

# Subscriptions

Deps.autorun ->
  Session.set('history_ready',false)
  safeSubscribe('pricesTime',Session.get('clock_end_stable'))  
  safeSubscribe('history',Session.get('clock_start_stable'),Session.get('clock_end_stable'), 5, {
    onReady: ->
      Session.set('history_ready',true)


  })

Template.time_slider.rendered = ->
  
  scale = d3.time.scale()
    .domain([EARLIEST,LATEST])
    .range([0,100])

  start = scale Session.get('clock_start')
  end = scale Session.get('clock_end')

  slider = $("#timeSlider").slider
    range: true
    min: 0
    max: 100
    values: [start, end]

  slider.on "slide", (event, ui) ->
    Session.set('clock_start', scale.invert ui.values[0])
    Session.set('clock_end', scale.invert ui.values[1])



Template.time_slider.events
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
