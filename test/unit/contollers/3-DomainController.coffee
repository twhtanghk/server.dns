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
		
	describe 'find', ->
		it 'domains', (done) ->
			req sails.hooks.http.app
				.get '/api/domain'
				.set 'Authorization', "Bearer #{tokens[0]}"
				.expect 200, done
				
	describe 'delete', ->
		it 'domain abc.com', (done) ->
			req sails.hooks.http.app
				.delete '/api/domain/abc.com'
				.set 'Authorization', "Bearer #{tokens[0]}"
				.expect 200, done					