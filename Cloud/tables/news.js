
/**
 * Created by fsgpino
 */

var azureMobileApps = require('azure-mobile-apps');

var table = azureMobileApps.table();

table.columns = {
	"userid" : "string",
    "title" : "string",
    "text": "string",
	"imageUUID": "string",
	"latitude": "number",
	"longitude": "number",
	"author": "string",
	"published": "bool",
	"sumratings": "number",
	"voters": "number",
};

table.dynamicSchema = false;

/*
*   Trigger para insert
*
* */

table.insert(function (context){

	if(context.item.title.length == 0){
        context.item.title = "No title";
    }

    if(context.item.text.length == 0){
        context.item.text = "No description";
    }

    if(context.item.author.length == 0){
        context.item.author = "Anonymous";
    }
	
    context.item.userid = context.user.id;
    context.item.published = false;
	context.item.sumratings = 0;
	context.item.voters = 0;
    
    return context.execute();
    
});

/*
* Permisos de acceso a la tabla
*
* */

table.read.access = 'anonymous';
table.update.access = 'disabled';
table.delete.access = 'authenticated';
table.insert.access = 'authenticated';

module.exports = table;
