Tilde ~ The FrankenREPL

Spawns a script/console-like console from your browser, which can communicate with
the rails server as if it were in a controller action. 

== Demo
Start rails and navigate to the root of the app to demo.

== Known Issues
* The magical underscore variable `_` doesn't work yet. 
* the session and request objects for the console are not updated for the contents of future requests

== Roadmap
* session reloading support
* execution in other controller contexts (users_controller, etc)
* gemification
