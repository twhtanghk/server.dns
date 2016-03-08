module.exports = 
	routes:
		# user
		'get /api/user':
			controller:		'UserController'
			action:			'find'
			
		'get /api/user/:id':
			controller:		'UserController'
			action:			'findOne'
			
		# record
		'get /api/record/:domain':
			controller:		'RecordController'
			action:			'find'
			
		'post /api/record':
			controller:		'RecordController'
			action:			'create'
			
		'delete /api/record':
			controller:		'RecordController'
			action:			'destroy'
			
		# domain
		'get /api/domain':
			controller:		'DomainController'
			action:			'find'
			
		'delete /api/domain/:domain':
			controller:		'DomainController'
			action:			'destroy'