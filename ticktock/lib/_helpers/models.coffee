_.extend(Meteor.Collection.prototype,
  
  findOrInsert: (obj) -> @findOne(obj) ? @findOne(@insert(obj))

)