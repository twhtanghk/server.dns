 # RecordController
 #
 # @description :: Server-side logic for managing records
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports =
	destroy: (req, res) ->
		Model = actionUtil.parseModel req
		values = actionUtil.parseValues req
		Model
			.destroy values
			.then (destroyed) ->
				if destroyed.length
					res.ok destroyed
				else
					res.notFound()
			.catch res.serverError