env = require '../../env.coffee'
fs = require 'fs'
require 'shelljs/global'

describe 'domain', ->
	@timeout env.timeout
	
	tokens = null
	users = env.users
	
	before (done) ->
		env.getTokens()
			.then (res) ->
				tokens = res
				done()
			.catch done
			
	describe 'read', ->
		it 'abc.com', (done) ->
			sails.models.domain
				.findOne 'abc.com'
				.populateAll()
				.then (domain) ->
					_.each domain.records, (record) ->
						record.domain = domain
					Promise.resolve domain
				.then (domain) ->
					domain
						.toStream()
						.pipe fs.createWriteStream '/tmp/db.abc.com'
						.on 'error', done
						.on 'finish', ->
							if exec('diff /tmp/db.abc.com conf.d/db.abc.com').code == 0
								done()
							else
								done new Error "mismatch domain zone data"
						
	describe 'touch', ->
		it 'abc.com', (done) ->
			sails.models.domain
				.findOne 'abc.com'
				.populateAll()
				.then (domain) ->
					domain.touch()
						.then ->
							done()
						.catch done