 # DomainController
 #
 # @description :: Server-side logic for managing domains
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports =
	destroy: (req, res) ->
		Model = actionUtil.parseModel req
		values = actionUtil.parseValues req
		Model
			.destroy name: values.domain
			.then (destroyed) ->
				if destroyed.length
					res.ok destroyed
				else
					res.notFound()
			.catch res.serverError