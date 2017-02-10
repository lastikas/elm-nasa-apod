require('./assets/css/normalize.css');
require('./assets/vendor/bootstrap-3.3.7-dist/css/bootstrap.min.css');
require('./assets/css/elm-datepicker.css');
require('./assets/css/apod.css');

var loading = require('./assets/images/loading.gif');
var error = require('./assets/images/blackhole.jpg');

var today = (Date.now());
var Elm = require('./Main.elm');
var root = document.getElementById('root');

Elm.Main.embed(root, {
    "initialDate" : today
    , "loadingImageSrc" : loading
    , "errorImageSrc" : error
    ,
});
