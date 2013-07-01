Session.setDefault('adding_stock',false)

SORT_TYPE = 'price'

Template.stock_list.stocks = function () {
  var current_user = Users.findOne(Session.get('user_id'));
  if (current_user) {
    var stocks = current_user.stocks();
    return _.sortBy(stocks,function(stock) {
      return SORT_TYPE == 'delta' ? -stock.deltaRelative() : -stock.price;
    });
  }
};

Template.stock_list.title = function () {
  var current_user = Users.findOne(Session.get('user_id'));
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
  // TODO: consider moving this into template code
  owners.forEach(function (owner) {
    if (owner._id != Session.get('user_id')) {
      names.push("<a href='/user/" + owner._id + "'>" + owner.name + "</a>");
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
});


Template.stock_control.rendered = function () {
  // implements typehead for stock symbol (match against name and symbol)
  // currently using a terrible hack and string splitting; Twitter's typeahead.js
  // is another option but doesn't support setting the source to a function.
  var delimiter = "####";
  
  $('#new_symbol').typeahead ({
    source: function (query, process) {
      var results = _.map(Stocks.find().fetch(), function (stock) { return stock.symbol + delimiter + stock.name; });
      process(results);
    },
    highlighter: function (item) {
      var symbol = item.split(delimiter)[0];
      var stock = Stocks.findOne({symbol: symbol});
      // TODO: return HTML instead
      return stock.name + " (" + stock.symbol + ")";
    },
    updater: function (item) {
      var symbol = item.split(delimiter)[0];
      return symbol;
    }
  });
  
  
  
};