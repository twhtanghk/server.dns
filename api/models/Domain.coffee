 # Domain.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models
stream = require 'stream'
fs = require 'fs'
_ = require 'lodash'
require 'shelljs/global'

module.exports =

	tableName:	'domain'
	
	schema:		true
	
	autoPK:		false
	
	attributes:
		name:		
			type:		'string'
			required:	true
			primaryKey:	true
			
		records:
			collection:	'record'
			via:		'domain'
		
		createdBy:
			model:		'user'
			required:	true
		
		lastUpdated: ->
			_.maxBy @records, 'createdAt'
				.createdAt
					
		# return readable stream with current domain zone data
		toStream: ->
			ret = new stream.Readable()
			ret._read = -> return
			_.each _.reverse(_.sortBy(@records, 'type')), (record) ->
				ret.push record.toLine() 
			ret.push null
			return ret
			
		dump: ->
			new Promise (resolve, reject) =>
				@toStream()
					.pipe fs.createWriteStream sails.config.file("db.#{@name}")
					.on 'error', reject
					.on 'finish', resolve
	
		# touch the domain serial no by drop and create SOA record
		touch: ->
			sails.models.record
				.findOne {type: 'SOA', domain: @name}
				.then (soa) ->
					sails.models.record
						.destroy soa
						.then ->
							sails.models.record
								.create soa

	# dump named.conf.local with all zone details
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
		
	afterCreate: (values, cb) ->
		sails.models.domain
			.dump()
			.then ->
				sails.models.domain.reload()
				cb()
	
	afterDestroy: (values, cb) ->
		sails.models.domain
			.dump()
			.then ->
				sails.models.domain.reload()
				cb()	