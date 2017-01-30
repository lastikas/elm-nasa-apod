require('./assets/css/normalize.css');
require('./assets/vendor/bootstrap-3.3.7-dist/css/bootstrap.min.css');

var loading = require('./assets/images/loading.gif');
var error = require('./assets/images/blackhole.jpg');

var today = (new Date()).toISOString().replace(/T.*/, "");
var Elm = require('./Main.elm');
var root = document.getElementById('root');

Elm.Main.embed(root, {
    "initialDate" : today
    , "loadingImageSrc" : loading
    , "errorImageSrc" : error
    ,
});
