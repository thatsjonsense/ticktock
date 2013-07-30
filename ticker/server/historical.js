PricesIntraday = new Meteor.Collection("prices_intraday"); // symbol, date, price

PricesDay = new Meteor.Collection("prices_day"); // symbol, date, open, close


// Store past stock data

Meteor.Router.add('/historical/:symbol/:days', function(symbol,days) {
  /*
  var date = {
  	year: parseInt(this.params.yyyy),
  	month: parseInt(this.params.mm),
  	day: parseInt(this.params.dd)
  }
  var datetime = new Date(date.year, date.month-1, date.day)
  */
  
  return getGoogleData(symbol,days);
});


function getNetfondsData(symbol,date,frequency) {
	// note: symbol here requires .O for Nasdaq, .N for NYSE, .A for AMEX. These are Reuters codes: http://en.wikipedia.org/wiki/Reuters_Instrument_Code i think


}

/*
Gets historical data about SYMBOL from the last DAYS days of trading
Returns intraday data for every FREQUENCY seconds, and daily data
Todo: storing in meteor
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
	var open_datetime;
	var open, close;

  // Iterate through the CSV
	_.each(lines,function(line,number) {

		var cols = line.split(',');

		// Opening tick or end of file
		if (cols[0][0] == 'a' || cols[0] == '') {

      // End of a day
      if (open_datetime) {

        // Save open/close data, if it's not already there
        var daily_data = {
          symbol: symbol,
          date: new Date(
            open_datetime.getYear(),
            open_datetime.getMonth(),
            open_datetime.getDate()
          ),
          open: open,
          close: close
        };
        PricesDay.findOne({symbol: daily_data.symbol, date: daily_data.date}) || PricesDay.insert(daily_data);
      
      }

      // End of file, get out of here!
      if (cols[0] == '') {
        return;
      }

      // Start a new day
			var timestamp = cols[0].slice(1);
			open_datetime = new Date(parseInt(timestamp) * 1000); // todo: timezone?
      var n = 0;
			open = cols[2]; // only set for first tick
			
		// Intraday ticks
		} else {
      var n = cols[0];
			close = cols[1]; // will update with every tick. last one is the closing price
		
    }

    var current_datetime = new Date(open_datetime.getTime() + (n * frequency * 1000));
    console.log(n,current_datetime,cols[1])

    // Save intraday data, if it's not already there
		var intraday_data = {
			symbol: symbol,
			date: current_datetime,
			price: parseFloat(cols[1])
		}
    PricesIntraday.findOne({symbol: intraday_data.symbol, date: intraday_data.date}) || PricesIntraday.insert(intraday_data);

	})

  return JSON.stringify({
    intraday: PricesIntraday.find({symbol: symbol}).fetch(),
    day: PricesDay.find({symbol: symbol}).fetch()
  },null,2);
}