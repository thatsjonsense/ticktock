


addedItems = (old_obj,new_obj) ->

  new_keys = _.difference(_.keys(new_obj), _.keys(old_obj))

  _.object([key, new_obj[key]] for key in new_keys)

###
x = {a: 1, b: 2}
y = {a: 1, c: 3}
addedItems(x, y) == 3
###

@SERVER_INTERVAL = 10*1000

if Meteor.isClient

  @subscriptions = []



  @safeSubscribe = (name,args...) ->

      debug "Subscribing to #{name} with args #{args}"
      handle = Meteor.subscribe(name,args...)
      sub =
        handle: handle
        name: name
        args: args

      subscriptions.push(sub)


  @unsubscribeAll = ->

    for sub in subscriptions
      debug "Unsubscribing from #{sub.name} with args #{sub.args}"
      sub.handle.stop()
  
  # This doesn't seem to work - probably cuz it kills web sockets on unload
  $(window).unload ->
   unsubscribeAll()


###
Consider combining this with the Meteor.publish function. Would let you add a lot more debugging/logging. For example, on every doc you could slap on _source = (the published name), bundling collection in with the updateArray definition, tracking the actual subscription things are part of, etc.
###

@pubArray = (updateArray,collection) ->

  return (opt...) ->

    debug "Publishing #{opt}"

    # both indexed by ID
    @client = {}
    @server = {}

    updateAndSync = =>
      sync_id = _.uniqueId()
      start_time = now()
      #debug 'Starting sync',sync_id,start_time.toISOString(),opt

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

      end_time = now()
      #debug 'Ending sync',sync_id,end_time.toISOString()
      #debug 'Time for sync',sync_id,'was',end_time.getTime() - start_time.getTime()

    @timer = Meteor.setIntervalInstant(updateAndSync,SERVER_INTERVAL)
    @onStop => 
      debug "Unpublishing #{opt}"
      if @timer? then Meteor.clearInterval(@timer)
