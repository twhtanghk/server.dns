module.exports = 
	policies:
		UserController:
			'*':		false
			find:		['isAuth']
			findOne:	['isAuth', 'user/me']
		RecordController:
			'*':		false
			find:		['isAuth', 'domain/isOwner']
			create:		['isAuth', 'setOwner', 'record/setIP']
			destroy:	['isAuth', 'domain/isOwner']
		DomainController:
			'*':		false
			find:		['isAuth']
			destroy:	['isAuth', 'domain/isOwner']