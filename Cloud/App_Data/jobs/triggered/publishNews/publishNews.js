
/**
 * Created by fsgpino
 */

var sql = require('mssql');

sql.connect("mssql://fsgpino:Genius123@boot3fsgpino.database.windows.net:1433/scoops?encrypt=true")
	.then(function() {
	
		new sql.Request().query("UPDATE news SET published = 1")
			.then(function(recordset) {
	        	console.log("All news published");
	    	}).catch(function(err) {
				console.error(err);
	    	});

	}).catch(function(err) {
    	console.error(err);
	});
