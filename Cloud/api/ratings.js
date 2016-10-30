
/**
 * Created by fsgpino
 */
 
 var api = {
	 
	 put : function (req, res, next) {
		 
		 // Chequear los parametros
		 if (typeof req.query["id"] === 'undefined')
             return next();
		 if (typeof req.query["rating"] === 'undefined')
             return next();
			
		 var query = {
			 sql: "SELECT id, userid FROM news WHERE id = '" + req.query["id"] + "'"
		 };
		 
		 req.azureMobile.data.execute(query)
		 	.then(function (result) {
				 if (result.length == 1) {
					 var updateQuery = {
						 sql: "UPDATE news SET sumratings = sumratings + " + req.query["rating"] + ", voters = voters + 1 WHERE id = '" + req.query["id"] + "'"
					 };
					 req.azureMobile.data.execute(updateQuery)
		 				.then(function (result) {
							/*var context = req.azureMobile;
							if (context.push) {
								var payload = '{"aps": {"alert": "Check the ratings! You have new rating!"}}';
								context.push.send(result[0].userid, payload, function (error) {
									if (error) {
								    	console.error(error);
								    }
								});
							}*/
							res.json("Sended");
					 	}, function (error) {
							console.error(error);
							res.status(500).send(error);
						});
				 } else {
					 res.status(404).send('Not found');
				 }
            }, function (error) {
				console.error(error);
				res.status(500).send(error);
			});
			
	 }
	 
 };
 
 api.put.access = 'anonymous';
 
 module.exports = api;
 