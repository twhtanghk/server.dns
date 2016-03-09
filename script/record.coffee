Sails = require 'sails'
Promise = require 'bluebird'
_ = require 'lodash'
lib = require './lib.coffee'

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
	
recordReady = (token, add, record) ->
	url = "#{sails.config.url}/api/record"
	func = if add then sails.services.rest().post else sails.services.rest().delete
	func token, url, record
		
argReady
	.then (data) ->
		lib.sailsReady
			.then (sails) ->
				lib.tokenReady sails, data.user
					.then (token) ->
						recordReady token, data.op, data.record
							.then (res) ->
								console.log res.statusCode
								console.log if res.body instanceof Buffer then res.body.toString() else res.body
		.finally Sails.lower
	.catch (err) ->
		console.log err
	.finally process.exit