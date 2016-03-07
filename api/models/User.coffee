 # User.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
	
	tableName:	'user'
	
	schema:		true
	
	autoPK:		false
	
	attributes:
		url:
			type: 		'string'
			required: 	true
			
		username:
			type: 		'string'
			required: 	true
			
		email:
			type:		'string' 
			required:	true
			primaryKey:	true