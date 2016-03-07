module.exports = 
	http:
		middleware:
			order: [
				'startRequestTimer'
				'bodyParser'
				'compress'
				'$custom'
				'router'
				'404'
				'500'
			]