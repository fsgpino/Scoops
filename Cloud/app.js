/**
 * Created by fsgpino
 */

var express = require('express'),
    azureMobileApps = require('azure-mobile-apps');

var app = express();

var app = express(),
    mobile = azureMobileApps( { swagger: process.env.NODE_ENV !== 'production'});

mobile.tables.import("./tables");
mobile.api.import("./api");

app.use(mobile);

app.listen(process.env.PORT || 3000);
