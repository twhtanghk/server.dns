actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

# replace dns A record param 'auto' with remote client IP req.connection.remoteAddress
module.exports = (req, res, next) ->
	values = req.body
	if values.type == 'A' and values.param[0] == 'auto'
		values.param = req.connection.remoteAddress.split(':').slice(-1)
	if values.type == 'AAAA' and values.param[0] == 'auto'
		values.param = [req.connection.remoteAddress]
	next()