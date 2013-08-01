_.extend(Meteor.Collection.prototype,
  
  findOrInsert: (obj) -> @findOne(obj) ? @insert(obj)

)