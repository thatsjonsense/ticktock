




Session.setDefault('timeLagMinutes',0)


Template.clock.timeNow = ->
  minutesAgo(Session.get('timeLagMinutes'))

Template.clock.events =
  'change .slider': (evt) ->
    value = parseInt($('.slider').val())
    Session.set('timeLagMinutes',-value)