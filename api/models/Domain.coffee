 # Domain.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models
stream = require 'stream'
fs = require 'fs'
_ = require 'lodash'
require 'shelljs/global'
dateFormat = require 'dateformat'

module.exports =

	tableName:	'domain'
	
	schema:		true
	
	autoPK:		false
	
	attributes:
		name:		
			type:		'string'
			required:	true
			primaryKey:	true
			
		sn:
			type:		'integer'
			required:	true
			defaultsTo:	0
			
		records:
			collection:	'record'
			via:		'domain'
		
		createdBy:
			model:		'user'
			required:	true
					
		# return readable stream with current domain zone data
		toStream: ->
			ret = new stream.Readable()
			ret._read = -> return
			_.each _.reverse(_.sortBy(@records, ['type', 'name'])), (record) ->
				ret.push record.toLine() 
			ret.push null
			return ret
			
		dump: ->
			new Promise (resolve, reject) =>
				@toStream()
					.pipe fs.createWriteStream sails.config.file("db.#{@name}")
					.on 'error', reject
					.on 'finish', resolve
	
		# return this domain serial no
		serial: ->
			"#{dateFormat(@updateAt, 'yyyymmdd')}#{('0' + @sn).slice(-2)}"
			
		# update the domain serial no
		touch: ->
			# get domain again instead of reference this domain to avoid circular reference
			sails.models.domain
				.findOne @name
				.then (domain) ->
					now = new Date()
					sameDay = (date1, date2) ->
						date1.getDate() == date2.getDate() and 
						date1.getMonth() == date2.getMonth() and
						date1.getFullYear() == date2.getFullYear()
					domain.sn = if sameDay(domain.updatedAt, now) then (domain.sn + 1) % 100 else 0
					domain.save()
						.then (domain) ->
							_.each domain.records, (record) ->
								record.domain = domain
							Promise.resolve domain
			 
	# dump named.conf.local
	dump: ->
		sails.models.domain
			.find()
			.then (domains) ->
				out = fs.createWriteStream sails.config.file('named.conf.local')
				_.each domains, (domain) ->
					out.write """
						zone \"#{domain.name}\" {
							type master;
							file \"#{sails.config.file("db.#{domain.name}")}\";
						};
						
					"""
			.catch sails.log.error
		
	# reload config
	reload: ->
		exec sails.config.reload
		
	beforeDestroy: (cond, cb) ->
		sails.models.record
			.destroy domain: cond.where.name
			.then ->
				cb()
			.catch cb
			
	afterCreate: (values, cb) ->
		sails.models.domain
			.dump()
			.then ->
				sails.models.domain.reload()
				cb()
			.catch cb
	
	afterDestroy: (values, cb) ->
		sails.models.domain
			.dump()
			.then ->
				sails.models.domain.reload()
				cb()	
			.catch cb