@Quotes = new Meteor.Collection("quotes")

Meteor.Router.add(
  '/test/prices': -> prettify(getPriceAtTime('GOOG',new Date("2013-07-30T19:21:00.000Z")))
  '/test/prices/:s/:d': (s,d) -> prettify(getPriceAtTime(s,new Date(d)))
)