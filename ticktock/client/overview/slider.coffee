Template.time_slider.rendered = ->
  $("#timeSlider").slider
    range: true
    min: 0
    max: 100
    values: [75, 90]



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