window.app.controller "LoginController", ($scope, $location, $rootScope, currentUser) ->

	$rootScope.title = "Login"

	currentUser.currentUser().then ( user ) ->
			$location.path('/dashboard')

	loginFunction = ->
		email = $scope.user.email
		password = $scope.user.password

		currentUser.authenticate(email, password).then () ->
			$location.path('/admin/dashboard')

	$scope.submit = loginFunction
	return

window.app.controller "DashboardController", ($scope, $location, $rootScope, currentUser) ->
	$rootScope.title = "Dashboard"

	currentUser.currentUser().then () ->
		$scope.user = user
		$scope.areas = user.areas
		$scope.firstname = user.firstName
		$scope.lastName = user.lastName
		console.log($scope.user)

	#$location.path "/dashboard" if user.roles is "Admin"
	return
