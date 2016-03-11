#!/usr/bin/coffee

Promise = require 'bluebird'
_ = require 'lodash'
lib = require './lib.coffee'
Sails = require 'sails'

argReady = new Promise (resolve, reject) ->
	help = """
		Usage: domain.coffee -u user -p pass --del name
			(e.g. 
				add dns A record:
					node_modules/.bin/coffee script/domain.coffee -u user -p pass --del abc.com 
			)
	"""
	argv = require('optimist').boolean('del').argv
	if argv.u and argv.p and argv.del and argv._.length >= 1 
		resolve
			user:
				id:		argv.u
				secret:	argv.p
			name:	argv._[0]
	else
		reject new Error help

domainReady = (token, name) ->
	url = "#{sails.config.url}/api/domain/#{name}"
	sails.services.rest().delete token, url
		
argReady
	.then (data) ->
		lib.sailsReady
			.then (sails) ->
				lib.tokenReady sails, data.user
					.then (token) ->
						domainReady token, data.name
							.then (res) ->
								console.log res.statusCode
								console.log if res.body instanceof Buffer then res.body.toString() else res.body
		.finally Sails.lower
	.catch (err) ->
		console.log err
	.finally process.exit