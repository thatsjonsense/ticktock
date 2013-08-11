



#Config

speed = 'slow'

if speed is 'fast'
  @max = 120

if speed is 'slow'
  @max = 60*60*24

Session.setDefault('virtualTime',null)
Session.setDefault('timeLag',20)

# Wait for timeLag to stabilize
current_timelag = null
previous_timelag = null
stableTimeLag = ->
  Session.setDefault('timeLagStable',Session.get('timeLag'))
  previous_timelag = current_timelag
  current_timelag = Session.get('timeLag')
  if previous_timelag == current_timelag
    Session.set('timeLagStable',current_timelag)
Meteor.setIntervalInstant(stableTimeLag,500)


@virtualTime = ->
  Session.get('virtualTime') ? now()


Meteor.setInterval(->
  Session.set('virtualTime',secondsAgo(Session.get('timeLag')))
,100)


Template.clock.minDelay = -> -@SERVER_INTERVAL * 2 / 1000
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