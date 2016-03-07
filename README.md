# server.dns
Restful Web Service for dns update

Server API
---------------------------------------------------------
## user

* attributes

	see [api/models/User.coffee](https://github.com/twhtanghk/server.dns/blob/master/api/models/User.coffee)
		
* api

	```
	get /api/user - list users for the specified pagination/sorting parameters skip, limit, sort
	get /api/user/me - read user attributes of current login user
	get /api/user/:id - read user attributes of the specifie
    ```
    
## record
* attributes

	see [api/models/User.coffee](https://github.com/twhtanghk/server.dns/blob/master/api/models/Record.coffee)
		
* api

	```
	post /api/record - create dns record with parameters { domain: 'domain name', name: 'host name/@', type: 'A|AAAA|NS', param: ['auto|domain|IP address'] } where auto is auto-filled with requested client IP
	delete /api/record - delete dns record with matching parameters { doamin: 'domain name', name='host name/@', type: 'A|AAAA|NS', param: optional ['domain|IP address'] } 
	```
	
Configuration
=============

*   git clone https://github.com/twhtanghk/server.dns.git
*   cd server.dns
*   npm install
*   copy config/env/development.coffee as config/env/production.coffee
*	update server url oauth2 client id and secret on config/env/production.coffee
```
	url:	'http://localhost:3000'
	client:
		id:		'client id'
		secret: 'client secret'
```
*	create dns A record by
```
	node_modules/.bin/coffee script/record.coffee -u user -p password --add abc.com www1 A auto
```
*	delete dns A records with hostname www
```
	node_modules/.bin/coffee script/record.coffee -u user -p password --del abc.com www A
```