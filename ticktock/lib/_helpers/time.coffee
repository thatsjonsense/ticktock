
@now = -> new Date()
@dateFromUnix = (timestamp) -> new Date(timestamp * 1000)

@secondsAfter = (t,s) -> new Date(t.getTime() + 1000 * s)
@secondsBefore = (t,s) -> secondsAfter(t, -s)
@secondsAgo = (s) -> secondsBefore(now(),s)

@minutesAfter = (t,m) -> secondsAfter(t, m * 60)
@minutesBefore = (t,m) -> secondsBefore(t, m * 60)
@minutesAgo = (m) -> minutesBefore(now(),m)

@hoursAfter = (t,h) -> minutesAfter(t, h * 60)
@hoursBefore = (t,h) -> minutesBefore(t, h * 60)
@hoursAgo = (m) -> hoursBefore(now(),m)

@daysAfter = (t,d) -> hoursAfter(t, d * 24)
@daysBefore = (t,d) -> hoursBefore(t, d * 24)
@daysAgo = (d) -> daysBefore(now(),d)

@weeksAfter = (t,w) -> daysAfter(t, w * 7)
@weeksBefore = (t,w) -> daysBefore(t, w * 7)
@weeksAgo = (w) -> weeksBefore(now(),w)



@defaultTime = -> if Meteor.isClient then virtualTime() else now()


Meteor.setIntervalInstant = (f,interval) ->
  f()
  handle = Meteor.setInterval(f,interval)
  return handle