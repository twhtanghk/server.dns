module.exports = 
	policies:
		UserController:
			'*':		false
			find:		['isAuth']
			findOne:	['isAuth', 'user/me']
		RecordController:
			'*':		false
			find:		true
			create:		['isAuth', 'setOwner', 'record/setIP']
			destroy:	['isAuth', 'domain/isOwner']