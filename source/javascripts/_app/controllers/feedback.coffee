window.app.controller "FeedBackController", ($scope, $rootScope, $location,$firebase, $routeParams, firebaseURL,currentUser) ->
	currentUser.requireLogin().then () ->
		$scope.ref = $firebase(new Firebase("#{firebaseURL}/bugs/manual")).$asArray()
		$scope.platform = null
		$scope.section = null
		$scope.attempt = null
		$scope.expectation = null
		$scope.result = null
		$scope.comments = null

		$scope.submit = ->
			feedback = {
				actual:$scope.result,
				bugId:null,
				comments:$scope.comments,
				doing:$scope.attempt,
				expect:$scope.expectation,
				platform:$scope.platform,
				time:2,
				view: $scope.section
			}
			console.log(feedback)
			$scope.ref.$add(feedback).then (id) ->
				id = id.key()
				ref = new Firebase("#{firebaseURL}/bugs/manual/#{id}")
				ref.child("bugId").set(id)
