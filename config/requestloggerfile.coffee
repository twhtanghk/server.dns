module.exports =
	requestloggerfile:
		format:			'[:date[clf]] :method :url :status :response-time ms'
		logLocation:	'file'
		inProduction:	true