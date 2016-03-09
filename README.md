# server.dns
Restful Web Service for dns update. Dump local zone files and reload named by sending HUP signal if zone or its records created or deleted

Server API
----------
## user

* attributes

	see [api/models/User.coffee](https://github.com/twhtanghk/server.dns/blob/master/api/models/User.coffee)
		
* api

	```
	get /api/user - list users for the specified pagination/sorting parameters skip, limit, sort
	get /api/user/me - read user attributes of current login user
	get /api/user/:id - read user attributes of the specified id (user email)
    ```
    
## record
* attributes

	see [api/models/User.coffee](https://github.com/twhtanghk/server.dns/blob/master/api/models/Record.coffee)
		
* api

	```
	get /api/record/:domain - list records for the specified domain name, pagination and sorting parameters skip, limit, sort
	post /api/record - create dns record with parameters { domain: 'domain name', name: 'host name|@', type: 'A|AAAA|NS', param: ['auto|domain|IP address'] } where auto is auto-filled with requested client IP
	delete /api/record - delete dns record with matching parameters { doamin: 'domain name', name='host name|@', type: 'A|AAAA|NS', param: optional ['domain|IP address'] } 
	```

## domain
* attributes

	see [api/models/User.coffee](https://github.com/twhtanghk/server.dns/blob/master/api/models/Domain.coffee)
		
* api

	```
	get /api/domain - list all domains for the specified pagination and sorting parameters skip, limit, sort
	delete /api/domain/:domain - delete the specified domain name and corresponding dns records 
	```
	
Configuration
-------------

## Server

*   git clone https://github.com/twhtanghk/server.dns.git
*   cd server.dns
*   npm install
*   copy config/env/development.coffee as config/env/production.coffee
*	update server port, database connection, oauth2 settings
```
	port:	3000
	connections:
		mongo:
			adapter:	'sails-mongo'
			driver:		'mongodb'
			host:		'localhost'
			port:		27017
			user:		'dnsrw'
			password:	'password'
			database:	'dns'
	oauth2:
		verifyURL:			'https://mob.myvnc.com/org/oauth2/verify/'
		scope:				[ "https://mob.myvnc.com/org/users"]
```
*	start server
```
	npm start
```

## Client for remotely updating dns record

*   git clone https://github.com/twhtanghk/server.dns.git
*   cd server.dns
*   npm install
*   copy config/env/development.coffee as config/env/production.coffee
*	update server url and oauth2 settings on config/env/production.coffee
```
	url:	'http://localhost:3000'
	oauth2:
		tokenUrl:			'https://mob.myvnc.com/org/oauth2/token/'
		scope:				[ "https://mob.myvnc.com/org/users"]
		client:
			id:		'client id'
			secret: 'client secret'
```
*	create dns NS, A record as below
```
	node_modules/.bin/coffee script/record.coffee -u user -p password --add abc.com @ A 10.1.1.1
	node_modules/.bin/coffee script/record.coffee -u user -p password --add abc.com @ NS ns1.abc.com.
	node_modules/.bin/coffee script/record.coffee -u user -p password --add abc.com ns1 A 10.1.1.1
	node_modules/.bin/coffee script/record.coffee -u user -p password --add abc.com www A 10.1.1.1
	node_modules/.bin/coffee script/record.coffee -u user -p password --add abc.com www A 10.1.1.2
	node_modules/.bin/coffee script/record.coffee -u user -p password --add abc.com ns2 CNAME ns1.abc.com.
```
*	delete dns A records with hostname www
```
	node_modules/.bin/coffee script/record.coffee -u user -p password --del abc.com www A
```

## vpn connect to remote server and update dns record

* follow the steps listed above to configure the client
* copy the script "script/vpn" to "/etc/init.d" and update project root directory "root", and vpn server "url" variables
* update the account details defined in "script/user.sh" and change mode to (600) read/write by owner only 
```
# openconnect user and password
export ocuser=user
export ocpass=password

# oauth2 user and password
export oauth2user=user
export oauth2pass=password
```
* run /etc/init.d/vpn start or stop to connect or disconnect to the vpn server