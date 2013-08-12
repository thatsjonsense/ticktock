



#Config

speed = 'slow'

if speed is 'fast'
  @max = 120

if speed is 'slow'
  @max = 60*60*24*3

Session.setDefault('virtualTime',null)
Session.setDefault('timeLag',0)


timeLagStable = ->
  Session.set('timeLagStable', Session.get('timeLag'))

Meteor.setIntervalInstant _.throttle(timeLagStable,500), 100


@virtualTime = ->
  Session.get('virtualTime') ? now()


Meteor.setInterval(->
  Session.set('virtualTime',secondsAgo(Session.get('timeLag')))
,1000)


Template.clock.minDelay = -> 0
Template.clock.sliderSize = -> -max
Template.clock.delay = -> Session.get('timeLag')
Template.clock.timeNow = -> @virtualTime()

Template.clock.events =
  'change .slider': (evt) ->
    value = parseInt($('.slider').val())
    Session.set('timeLag',-value)

    ###
    if value == 0
      Session.set('virtualTime',null)
    else
      Session.set('virtualTime',minutesAgo(-value))
    ###