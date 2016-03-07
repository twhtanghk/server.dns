http = require 'needle'
fs = require 'fs'
util = require 'util'

dir = '/etc/ssl/certs'
files = fs.readdirSync(dir).filter (file) -> /.*\.pem/i.test(file)
files = files.map (file) -> "#{dir}/#{file}"
ca = files.map (file) -> fs.readFileSync file

###
options = 
	timeout:	10000
	agent:		new agent('http://proxy1.scig.gov.hk:8080')
###
module.exports = (options = sails.config.http.opts || {}) ->
	_.defaults options, 
		ca:			ca
	
	get: (token, url) ->
		new Promise (fulfill, reject) ->
			opts =
				headers:
					Authorization:	"Bearer #{token}"
			_.extend opts, options
			http.get url, opts, (err, res) ->
				if err
					return reject err
				fulfill res
				
	post: (token, url, data) ->
		new Promise (fulfill, reject) ->
			opts =
				headers:
					Authorization:	"Bearer #{token}"
			_.extend opts, options
			http.post url, data, opts, (err, res) ->
				if err
					return reject err
				fulfill res
					
	push: (token, roster, msg) ->
		param =
			roster: roster
			msg:	msg
		data = _.mapValues sails.config.push.data, (value) ->
			_.template value, param
		ret = @post token, sails.config.push.url, 
				users:	[roster.createdBy.email]
				data:	data
		new Promise (fulfill, reject) ->
			ret	
				.then (res) ->
					sails.log.debug util.inspect data
					sails.log.info util.inspect res.body
					fulfill res
				.catch (err) ->
					sails.log.error err
					reject err
			
	gcmPush: (users, data) ->
		new Promise (fulfill, reject) ->
			opts = 
				headers:
					Authorization: 	"key=#{sails.config.push.gcm.apikey}"
					'Content-Type': 'application/json'
				json:		true
			_.extend opts, options
			devices = []
			_.each users, (user) ->
				_.each user.devices, (device) ->
					devices.push device.regid 
			defaultMsg =
				title:		'Instant Messaging'
				message:	' '
			data =
				registration_ids:	_.uniq(devices)
				data:				_.extend defaultMsg, data
			http.post sails.config.push.gcm.url, data, opts, (err, res) =>
				if err
					return reject(err)
				fulfill(res.body)
				
	# get token for Resource Owner Password Credentials Grant
	# url: 	authorization server url to get token 
	# client:
	#	id: 	registered client id
	#	secret:	client secret
	# user:
	#	id:		registered user id
	#	secret:	user password
	# scope:	[ "https://mob.myvnc.com/org/users", "https://mob.myvnc.com/mobile"]
	token: (url, client, user, scope) ->
		opts = 
			'Content-Type':	'application/x-www-form-urlencoded'
			username:		client.id
			password:		client.secret
		_.extend opts, options
		data =
			grant_type: 	'password'
			username:		user.id
			password:		user.secret 
			scope:			scope.join(' ')
		new Promise (fulfill, reject) ->
			http.post url, data, opts, (err, res) ->
				if err
					return reject err
				fulfill res