fs = require 'fs'
Sails = require 'sails'
Promise = require 'bluebird'
http = require 'needle'
_ = require 'lodash'

argReady = new Promise (resolve, reject) ->
	help = """
		Usage: record domain name type param
			(e.g. 
				add dns A record:
					node_modules/.bin/coffee script/record.coffee -u user -p pass --add abc.com www1 A 10.1.1.1
				del dns NS records: 
					node_modules/.bin/coffee script/record.coffee -u user -p pass --del abc.com ns2 NS
				del dns CNAME record:
					node_modules/.bin/coffee script/record.coffee -u user -p pass --del abc.com www CNAME www1 
			)
	"""
	argv = require('optimist').boolean('add').boolean('del').argv
	if argv.u and argv.p and ((argv.add and argv._.length >= 4) or (argv.del and argv._.length >= 3)) 
		resolve
			user:
				id:		argv.u
				secret:	argv.p
			op:
				argv.add
			record:
				domain:	argv._[0]
				name:	argv._[1]
				type:	argv._[2]
				param:	argv._.slice 3
	else
		reject new Error help
	
sailsReady = new Promise (resolve, reject) ->
	config =
		environment: 'production'
		hooks:
			grunt:			false
			i18n:			false
			views:			false
			csrf:			false
			session:		false
			blueprints:		false
			controllers:	false
			cors:			false
			http:			false
			orm:			false
			policies:		false
			pubsub:			false
			sockets:		false
			userhooks:		false
	Sails.lift config, (err, sails) ->
		if err
			return reject err
		resolve sails

tokenReady = (sails, user, client = sails.config.oauth2.client) ->
	sails.services.rest()
		.token sails.config.oauth2.tokenUrl, client, user, sails.config.oauth2.scope
		.then (res) ->
			if res.statusCode != 200
				return Promise.reject new Error res.body.error_description  
			res.body.access_token
	
recordReady = (token, add, record) ->
	url = "#{sails.config.url}/api/record"
	func = if add then sails.services.rest().post else sails.services.rest().delete
	func token, url, record
		
argReady
	.then (data) ->
		sailsReady
			.then (sails) ->
				tokenReady sails, data.user
					.then (token) ->
						recordReady token, data.op, data.record
							.then (res) ->
								console.log res.statusCode
								console.log res.body
		.finally Sails.lower
	.catch (err) ->
		console.log err
	.finally process.exit