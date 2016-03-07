env = require '../../env.coffee'
req = require 'supertest'		
path = require 'path'
util = require 'util'
fs = require 'fs'
_ = require 'lodash'

describe 'RecordController', ->
	@timeout env.timeout
	
	tokens = null
	
	before (done) ->
		env.getTokens()
			.then (res) ->
				tokens = res
				done()
			.catch done
		
	describe 'create dns record', ->
		it 'A', (done) ->
			req sails.hooks.http.app
				.post '/api/record'
				.send
					domain:		'abc.com'
					name:		'www'
					type:		'A'
					param:		['10.1.1.1']
				.set 'Authorization', "Bearer #{tokens[0]}"
				.expect 201, done
		
		it 'invalid A', (done) ->
			req sails.hooks.http.app
				.post '/api/record'
				.send
					domain:		'abc.com'
					name:		'www'
					type:		'A'
					param:		['abc']
				.set 'Authorization', "Bearer #{tokens[0]}"
				.expect 500, done		