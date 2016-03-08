module.exports =
	timeout: 4000000
	users: [
		{ id: 'user1', secret: 'password1', email: "email1" }
		{ id: 'user2', secret: 'password2', email: "email2" }
	]
	getTokens: ->
		url = sails.config.oauth2.tokenUrl
		scope = sails.config.oauth2.scope
		Promise
			.all [
				sails.services.rest().token url, sails.config.oauth2.client, module.exports.users[0], scope
				sails.services.rest().token url, sails.config.oauth2.client, module.exports.users[1], scope
			] 
			.then (res) ->
				new Promise (resolve, reject) ->
					_.each res, (response) ->
						if response.statusCode != 200
							reject response.body
					resolve res
			.then (res) ->
				_.map res, (response) ->
					response.body.access_token
	getUsers: ->
		sails.models.user
			.find username: _.map module.exports.users, (user) ->
				user.email