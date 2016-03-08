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
		
		it 'MX', (done) ->
			req sails.hooks.http.app
				.post '/api/record'
				.send
					domain:		'abc.com'
					name:		'@'
					type:		'MX'
					param:		[10, 'mail.abc.com.']
				.set 'Authorization', "Bearer #{tokens[0]}"
				.expect 201, done
		
		it 'CNAME', (done) ->
			req sails.hooks.http.app
				.post '/api/record'
				.send
					domain:		'abc.com'
					name:		'www'
					type:		'CNAME'
					param:		['www1']
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
				
	describe 'find', ->
		it 'records for abc.com', (done) ->
			req sails.hooks.http.app
				.get '/api/record/abc.com'
				.set 'Authorization', "Bearer #{tokens[0]}"
				.expect 200, done
	
	describe 'delete', ->
		it 'www A records for abc.com', (done) ->
			req sails.hooks.http.app
				.delete '/api/record'
				.send
					domain:		'abc.com'
					name:		'www'
					type:		'A'
				.set 'Authorization', "Bearer #{tokens[0]}"
				.expect 200, done					