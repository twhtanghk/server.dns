env = require '../../env.coffee'

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
			
	describe 'create', ->
		it 'NS', (done) ->
			sails.models.record
				.create
					domain:		'abc.com'
					name:		'ns1'
					type:		'NS'
					param:		['ns1.abc.com.']
					createdBy:	users[0].email
				.then (created) ->
					done()
				.catch done
				
		it 'A', (done) ->
			sails.models.record
				.create
					domain:		'abc.com'
					name:		'www'
					type:		'A'
					param:		['10.1.1.1']
					createdBy:	users[0].email
				.then (created) ->
					done()
				.catch done