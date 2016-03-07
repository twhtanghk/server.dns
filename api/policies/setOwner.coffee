module.exports = (req, res, next) ->
	req.options.values = req.options.values || {}
	req.options.values.createdBy = req.user
	next()