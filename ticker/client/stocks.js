Session.setDefault('adding_stock',false)

SORT_TYPE = 'price'

Template.stock_list.stocks = function () {
  var current_user = Users.findOne(Session.get('user_id'))
  if (current_user) {
    var stocks = current_user.stocks()
    return _.sortBy(stocks,function(stock) {
      return SORT_TYPE == 'delta' ? -stock.deltaRelative() : -stock.price
    })
  }
};

Template.stock_list.title = function () {
  var current_user = Users.findOne(Session.get('user_id'))
  if (current_user) {
    return current_user.name + "'s portfolio";
  }
}

Template.stock.updown = function () {
  return this.deltaAbsolute() >= 0 ? "up": "down";
}


// TODO: make this aware of logged in user AND user in focus
Template.stock.ownersString = function () {
  var self = this;
  var owners = self.owners();
  
  var names = [];
  owners.forEach(function (owner) {
    if (owner._id != Session.get('user_id')) {
      names.push(owner.name);
    }
  });
  
  switch (names.length) {
    case 0:
      return "";
    case 1:
      return names[0] + " owns this";
    case 2:
      return names[0] + " and " + names[1] + " own this";
    case 3:
      return names[0] + ", " + names[1] + ", and " + names[2] + " own this";
    default:
      var numLeft = names.length - 2;
      return names[0] + ", " + names[1] + ", and " + numLeft + " others own this";
  }

};

// Adding a new stock to portfolio
Template.stock_control.events({
  'click #add_stock': function (evt) {
    $('#new_stock').show();
    $('#add_stock').hide();
    $('#new_stock .symbol').val('').focus();
  },
  
  'blur #new_stock input': function (evt) {
    // if all of the fields are blank, clear
    if ($('#new_stock .symbol').val() == "" &&
        $('#new_stock .shares').val() == "" &&
        $('#new_stock .cost_basis').val() == "") {
        $('#new_stock').hide();
        $('#add_stock').show();
        }
  },
    
  'click .submit': function (evt) {
    Users.update(
      Session.get('user_id'),
      {$push: {investments: {
        symbol: $('#new_stock .symbol').val(),
        shares: $('#new_stock .shares').val(),
        price: null,
        cost_basis: $('#new_stock .cost_basis').val()
      }}});
    // clear values out of control and bring back focus
    $('#new_stock .symbol').val('').focus();
    $('#new_stock .shares').val('');
    $('#new_stock .cost_basis').val('');
    
  }
})
