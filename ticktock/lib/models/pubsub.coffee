


addedItems = (old_obj,new_obj) ->

  new_keys = _.difference(_.keys(new_obj), _.keys(old_obj))

  _.object([key, new_obj[key]] for key in new_keys)

###
x = {a: 1, b: 2}
y = {a: 1, c: 3}
addedItems(x, y) == 3
###

SERVER_INTERVAL = 5000

if Meteor.isClient

  Session.setDefault('subscriptions',[])

  @safeSubscribe = (name,args...) ->

      print "Subscribing to #{name} with args #{args}"
      handle = Meteor.subscribe(name,args...)

      #print 'subscriptions', Session.get('subscriptions')

      Deps.nonreactive ->
        sub =
          handle: handle
          name: name
          args: args

        subs = Session.get('subscriptions')
        subs.push(sub)
        Session.set('subscriptions',subs)

  # todo: find a place to call this. JS to detect refresh or leaving page?
  @unsubscribeAll = ->

    subs = Session.get('subscriptions') or []

    for sub in subs
      print "Unsubscribing from #{sub.name} with args #{sub.args}"
      print sub.handle
      if not sub.handle.stop?()
        print "Couldn't unsubscribe, handle was #{sub.handle}"

    Session.set('subscriptions',[])





###
Consider combining this with the Meteor.publish function. Would let you add a lot more debugging/logging. For example, on every doc you could slap on _source = (the published name), bundling collection in with the updateArray definition, tracking the actual subscription things are part of, etc.
###

@pubArray = (updateArray,collection) ->

  return (opt...) ->

    # both indexed by ID
    @client = {}
    @server = {}

    updateAndSync = =>
      #sync_id = _.uniqueId()
      #print 'Starting sync',sync_id,now().toISOString(),opt

      @server = _.object([doc._id, doc] for doc in updateArray(opt...))

      fresh = addedItems(@client,@server) # on server but not client
      stale = addedItems(@server,@client) # on client but not server

      for id, doc of fresh
        #print "Sending fresh #{id} to client"
        @client[id] = doc
        @added(collection,id,doc)

      for id, doc of stale
        #print "Deleting stale #{id} from client"
        delete @client[id]
        @removed(collection,id)

      #print 'Ending sync',sync_id,now().toISOString()

    @timer = Meteor.setIntervalInstant(updateAndSync,SERVER_INTERVAL)
    @onStop => if @timer? then Meteor.clearInterval(@timer)
