actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = (req, res, next) ->
	if actionUtil.requirePk(req) == 'me'
		req.options.id = req.user.id
	next()