agent = require 'https-proxy-agent'

module.exports =
	port:			3000
	hookTimeout:	400000
	url:		'http://localhost:3000'
	reload:		'killall -HUP named'
	oauth2:
		tokenUrl:			'https://mob.myvnc.com/org/oauth2/token/'
		verifyURL:			'https://mob.myvnc.com/org/oauth2/verify/'
		scope:				[ "https://mob.myvnc.com/org/users"]
		client:
			id:		'client id'
			secret: 'client secret'
	soa:	[300, 180, 1209600, 300] # [refresh, retry, expire, ttl]
	file: (name) ->
		"conf.d/#{name}"
	models:
		connection: 'mongo'
		migrate:	'alter'
	connections:
		mongo:
			adapter:	'sails-mongo'
			driver:		'mongodb'
			host:		'localhost'
			port:		27017
			user:		'dnsrw'
			password:	'password'
			database:	'dns'
	log:
		level:		'silly'
	http:
		opts:
			agent:	new agent('http://proxy1.scig.gov.hk:8080')