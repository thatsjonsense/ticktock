Meteor.Router.add({
  
  '/user/:user_id': function(id) {
    Session.set('user_id',id)
    return 'dashboardStocks'
  },
  '': 'dashboardUsers',
  '/chart': 'chart' 
});


Meteor.Router.beforeRouting = function() {
  Session.set('user_id',null)
}