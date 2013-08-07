



#Config

speed = 'fast'

if speed is 'fast'
  @interval = 10
  @max = 120

if speed is 'slow'
  @interval = 60
  @max = 60*24

Session.setDefault('virtualTime',null)
Session.setDefault('timeLag',10)


@virtualTime = ->
  Session.get('virtualTime') ? now()


Meteor.setInterval(->
  Session.set('virtualTime',secondsAgo(Session.get('timeLag')))
,1000)

Template.clock.minDelay = -> -@SERVER_INTERVAL * 2 / 1000
Template.clock.sliderSize = -> -max
Template.clock.delay = -> Session.get('timeLag')
Template.clock.timeNow = -> @virtualTime()

Template.clock.events =
  'mouseup .slider': (evt) ->
    value = parseInt($('.slider').val())
    Session.set('timeLag',-value)

    ###
    if value == 0
      Session.set('virtualTime',null)
    else
      Session.set('virtualTime',minutesAgo(-value))
    ###