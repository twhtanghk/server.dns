actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

# check if authenticated user is model owner  
module.exports = (req, res, next) ->
	values = actionUtil.parseValues req
	cond = 
			name:		values.domain
			createdBy:	req.user.email
	sails.models.domain
		.find cond
		.then (records) ->
			 if records.length
			 	next()
			 else
			 	res.forbidden new Error "domain #{cond.name} not found"
		.catch res.serverError