module.exports = 
	bootstrap:	(cb) ->
		Object.defineProperty Error.prototype, 'message',
			configurable: true
			enumerable: true
		cb()