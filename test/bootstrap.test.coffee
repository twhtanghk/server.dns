env = require './env.coffee'
fs = require 'fs'
config = JSON.parse fs.readFileSync './.sailsrc'

Sails = require 'sails'

before (done) ->
	@timeout env.timeout

	Sails.lift config, (err, sails) ->
		if err
			return done err
    
		done err, sails
		
after (done) ->
	Sails.lower done