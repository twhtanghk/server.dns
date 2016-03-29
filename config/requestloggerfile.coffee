module.exports =
	requestloggerfile:
		format:			'[:date[clf]] :method :url :status :response-time ms'
		logLocation:	'file'
		fileLocation: 	'log/access.log'
		inProduction:	true