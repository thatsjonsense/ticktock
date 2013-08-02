


Meteor.startup ->

  
  Meteor.setInterval(->


    # Dumb implementation: only keep the last 500 quotes. This sucks!
  
    MAX_QUOTES = 500

    to_purge = Quotes.find({}).fetch()[...-500]


    #if to_purge then console.log('Purging',to_purge.length,'quotes')
    for quote in to_purge
      Quotes.remove(quote)

  , 60*1000)