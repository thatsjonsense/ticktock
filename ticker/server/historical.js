Prices = new Meteor.Collection("prices")

// Store past stock data

Meteor.Router.add({
  '/historical/:symbol/:days': function(symbol,days) {
    return getGoogleData(symbol,days);
  },
  '/historical/dump': function () {
    // todo: output all historical data to a .json file which we can save
  }
});


function getNetfondsData(symbol,date,frequency) {
	// note: symbol here requires .O for Nasdaq, .N for NYSE, .A for AMEX. These are Reuters codes: http://en.wikipedia.org/wiki/Reuters_Instrument_Code i think


}

/*
Gets historical data about SYMBOL from the last DAYS days of trading
Returns intraday data for every FREQUENCY seconds
*/
function getGoogleData(symbol,days,frequency) {
	
  // Construct URL, using defaults if needed
	var frequency = frequency || 60;
  var days = days || 1;
  var googleUrl = "http://www.google.com/finance/getprices?i=[INTERVAL]&p=[DAYS]d&f=d,o,h,l,c,v&df=cpct&q=[SYMBOL]"
		.replace('[INTERVAL]',frequency)
		.replace('[DAYS]',days)
		.replace('[SYMBOL]',symbol);

  // Call server and process response
	var response = Meteor.http.get(googleUrl); // todo: handle errors
	var lines = response.content.split('\n');
	var lines = lines.slice(7); // get rid of the header and last line

  // State for the loop
	var open_datetime, close_datetime;
  var tick_open_datetime, tick_close_datetime;
	var open, close;

  // Iterate through the CSV
	_.each(lines,function(line,number) {

		var cols = line.split(',');

		// Opening tick
		if (cols[0][0] == 'a') {

			var timestamp = cols[0].slice(1);
			open_datetime = new Date(parseInt(timestamp) * 1000); // todo: timezone?
      var n = 0;
			
		// Intraday ticks
		} else {
      var n = cols[0];
    }

    tick_open_datetime = new Date(open_datetime.getTime() + ((n-1) * frequency * 1000));
    tick_close_datetime = new Date(open_datetime.getTime() + (n * frequency * 1000));

    // Save intraday data, if it's not already there
		var intraday_data = {
			symbol: symbol,
			open_date: tick_open_datetime,
      close_date: tick_close_datetime,
      open: parseFloat(cols[4]),
			close: parseFloat(cols[1])
		}
    Prices.findOne({symbol: intraday_data.symbol, open_date: intraday_data.open_date, close_date: intraday_data.close_date}) || Prices.insert(intraday_data);

	})

  return JSON.stringify({
    prices: Prices.find({symbol: symbol}).fetch()
  },null,2);
}