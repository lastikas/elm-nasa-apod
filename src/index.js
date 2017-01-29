require('./assets/css/normalize.css');
require('./assets/vendor/bootstrap-3.3.7-dist/css/bootstrap.min.css');

var today = (new Date()).toISOString().replace(/T.*/, "");
var Elm = require('./Main.elm');
var root = document.getElementById('root');

Elm.Main.embed(root, today);
