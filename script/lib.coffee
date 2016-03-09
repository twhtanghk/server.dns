Sails = require 'sails'
Promise = require 'bluebird'

module.exports = 
	sailsReady: new Promise (resolve, reject) ->
		config =
			environment: 'production'
			hooks:
				grunt:			false
				i18n:			false
				views:			false
				csrf:			false
				session:		false
				blueprints:		false
				controllers:	false
				cors:			false
				http:			false
				orm:			false
				policies:		false
				pubsub:			false
				sockets:		false
				userhooks:		false
		Sails.lift config, (err, sails) ->
			if err
				return reject err
			resolve sails
	
	tokenReady: (sails, user, client = sails.config.oauth2.client) ->
		sails.services.rest()
			.token sails.config.oauth2.tokenUrl, client, user, sails.config.oauth2.scope
			.then (res) ->
				if res.statusCode != 200
					return Promise.reject new Error res.body.error_description  
				res.body.access_token