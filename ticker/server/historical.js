// Store past stock data

Meteor.Router.add('/historical/:symbol/:mm-:dd-:yyyy', function() {
  var date = {
  	year: parseInt(this.params.yyyy),
  	month: parseInt(this.params.mm),
  	day: parseInt(this.params.dd)
  }
  var datetime = new Date(date.year, date.month-1, date.day)

  var symbol = this.params.symbol
  //console.log(date,datetime)

  return getGoogleData(symbol,1);
});


function getHistoricalData(symbol,date,frequency) {
	// note: symbol here requires .O for Nasdaq, .N for NYSE, .A for AMEX. These are Reuters codes: http://en.wikipedia.org/wiki/Reuters_Instrument_Code i think


}

/*
Gets historical data about SYMBOL from the last DAYS days of trading
Returns intraday data for every FREQUENCY seconds, and daily data
Todo: storing in meteor
*/
function getGoogleData(symbol,days,frequency) {
	
	var frequency = frequency || 60; // Seconds between updates. Min 60.
	
	var googleUrl = "http://www.google.com/finance/getprices?i=[INTERVAL]&p=[DAYS]d&f=d,o,h,l,c,v&df=cpct&q=[SYMBOL]"
		.replace('[INTERVAL]',frequency)
		.replace('[DAYS]',2)
		.replace('[SYMBOL]',symbol);

	console.log(googleUrl);

	var response = Meteor.http.get(googleUrl);
	// todo: handle errors
	var lines = response.content.split('\n');
	var lines = lines.slice(7,-1); // get rid of the header and last line

	//console.log(lines);

	var current_datetime;
	var current_date;
	var opens = {}
	var closes = {}


	_.each(lines,function(line,number) {

		var cols = line.split(',');

		// Opening tick
		if (cols[0][0] == 'a') {
			var timestamp = cols[0].slice(1);
			current_datetime = new Date(parseInt(timestamp) * 1000); // todo: timezone?
			current_date = current_datetime.toLocaleDateString();
			opens[current_date] = cols[2]; // only set for first tick
			
		// Intraday ticks
		} else {
			current_datetime.setTime(current_datetime.getTime() + frequency * 1000);
			closes[current_date] = cols[1]; // will update with every tick
		}

		var data = {
			symbol: symbol,
			date: current_datetime,
			price: parseFloat(cols[1])
		}

	
	})

}