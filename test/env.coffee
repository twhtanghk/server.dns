module.exports =
	timeout: 4000000
	users: [
		{ id: 'user1', secret: 'password1', email: "email1" }
		{ id: 'user2', secret: 'password2', email: "email2" }
	]
	getTokens: ->
		new Promise (fulfill, reject) ->
			url = 'https://mob.myvnc.com/org/oauth2/token/'
			scope = [ "https://mob.myvnc.com/org/users"]
			Promise
				.all [
					sails.services.rest().token url, sails.config.oauth2.client, module.exports.users[0], scope
					sails.services.rest().token url, sails.config.oauth2.client, module.exports.users[1], scope
				] 
				.then (res) ->
					fulfill _.map res, (response) ->
						response.body.access_token
				.catch reject
	getUsers: ->
		sails.models.user
			.find username: _.map module.exports.users, (user) ->
				user.email