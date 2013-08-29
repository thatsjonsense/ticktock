LATEST = now()
EARLIEST = daysAgo(2)

Session.setDefault('clock_end', minutesAgo(5))
Session.setDefault('clock_start', hoursAgo(6.5))


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




Template.time_slider.start = ->
  Session.get('clock_start')

Template.time_slider.end = ->
  Session.get('clock_end')


###
  updateClock = (event, ui) ->


    $('.time_slider .clock').html ->
     Template.time_clock
      start: time_scale.invert ui.values[0]
      end: time_scale.invert ui.values[1]




  slider.on "slide", updateClock
###















###
  $( "#slider-range" ).slider({
      range: true,
      min: 0,
      max: 500,
      values: [ 75, 300 ],
      slide: function( event, ui ) {
        $( "#amount" ).val( "$" + ui.values[ 0 ] + " - $" + ui.values[ 1 ] );
      }
    });
###