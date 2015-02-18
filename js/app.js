/**
 * Created by Jorge Cedi Voirol on 17/02/15.
 */
requirejs.config({
    waitSeconds : 520,
    "baseUrl": "js/lib",
    "paths": {
        "app": "../app",
        "handlebars": "handlebars",
        "async": "async",
        "jquery": "//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min",
        "jquery-cookie": "//cdnjs.cloudflare.com/ajax/libs/jquery-cookie/1.4.1/jquery.cookie.min",
        "underscore": "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.7.0/underscore-min",
        "backbone": "//cdnjs.cloudflare.com/ajax/libs/backbone.js/1.1.2/backbone-min",
        "geoPosition": "geoPosition"
    },
    "shim":{
        "handlebars":{
            "exports": "Handlebars"
        }
    }
});

// Load the main app module to start the app
requirejs(["app/map"]);