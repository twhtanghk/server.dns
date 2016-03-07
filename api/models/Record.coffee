 # Domain.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models
validator = require 'validator'
dateFormat = require 'dateformat'

getDomain = (domain) ->
	if typeof domain == 'string' 
		sails.models.domain
			.findOne(domain)
			.populateAll()
			.then (domain) ->
				_.each domain.records, (record) ->
					record.domain = domain
				Promise.resolve domain	
	else
		Promise.resolve(domain)
	
module.exports =

	tableName:	'record'
	
	schema:		true
	
	attributes:
		domain:
			model:		'domain'
			required:	true
			
		name:			
			type:		'string'
			required:	true
		
		type:
			type:		'string'
			'in':		['SOA', 'A', 'AAAA', 'NS']
			required:	true
			
		param:
			type:		'array'
			required:	true
			array:		true
			
		createdBy:
			model:		'user'
			required:	true
			
		toLine: ->
			switch @type
				when 'SOA'
					[refresh, retry, expire, ttl] = @param
					"#{@name} IN #{@type} ns1.#{@domain.name}. #{@createdBy}. (#{dateFormat(@domain.lastUpdated(), 'yyyymmddHHMMss')} #{refresh} #{retry} #{expire} #{ttl})\n"
				else
					"#{@name} IN #{@type} #{@param[0]}\n"

	beforeCreate: (values, cb) ->
		# promise to autocreate domain if not defined before
		domainReady = sails.models.domain
			.findOrCreate 
				name: 		values.domain
				createdBy:	values.createdBy
				
		# promise to autocreate domain soa record if current record is not soa
		soa =  
			domain:		values.domain
			name:		'@'
			type:		'SOA'
			param:		sails.config.soa
			createdBy:	values.createdBy
		soaReady = if values.type == 'SOA' then Promise.resolve() else sails.models.record.findOrCreate _.pick(soa, 'domain', 'name', 'type'), soa
			
		domainReady
			.then (domain) ->
				# check if domain owner == record owner 
				if domain.createdBy == values.createdBy
					soaReady
						.then ->
							cb()
				else
					Promise.reject new Error "Unauthorized to create record on domain #{domain.name} created by #{domain.createdBy}"
			.catch cb
			
	afterValidate: (values, cb) ->
		# promise to validate dns record type and param
		check = 
			SOA: (param) ->
				[refresh, retry, expire, ttl] = param
				typeof refresh == 'number' and
				typeof retry == 'number' and
				typeof expire == 'number' and
				typeof ttl = 'number'
			A: (param) ->
				[ip] = param
				validator.isIP ip, 4
			AAAA: (param) ->
				[ip] = param
				validator.isIP ip, 6
			NS: (param) ->
				[server] = param
				validator.isFQDN server,
					require_tld: 		false
					allow_underscores:	false
					allow_trailing_dot:	true
		if check[values.type](values.param)
			cb()
		else
			cb new Error "invalid record type #{values.type} and param #{values.param}"
			
	afterCreate: (record, cb) ->
		getDomain record.domain
			.then (domain) ->
				domain.dump()
					.then cb
			.catch cb 	
		
	afterUpdate: (record, cb) ->
		getDomain record.domain
			.then (domain) ->
				domain.dump()
					.then cb
			.catch cb 	
			
	afterDestroy: (records, cb) ->
		Promise
			.all _.map records, (record) ->
				getDomain record.domain
			.then (domains) ->
				Promise
					.all _.map domains, (domain) ->
						domain.dump()
					.then ->
						cb()
			.catch cb