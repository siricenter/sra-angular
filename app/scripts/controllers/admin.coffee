"use strict"
window.app.controller "AdminAreasController", ($scope, $location, $firebase, $routeParams, $rootScope, firebaseURL) ->
  $rootScope.currentUser = JSON.parse(sessionStorage.getItem("user"))
  regions = JSON.parse(localStorage.regions)
  if regions isnt `undefined`
    
    # Don't define functions inside a loop. It's a performance killer.
    callMe = (areaData) ->
      areasArr.push areaData
      areas = []
      $scope.areas = areas.concat.apply(areas, areasArr)
      return

    i = 0

    while i < regions.length
      ref = new Firebase(firebaseURL + "Organizations/SRA/Regions/" + regions[i] + "/Areas")
      sync = $firebase(ref).$asArray()
      areasArr = []
      sync.$loaded().then callMe #Maybe?
      i++
  return

window.app.controller "AdminDashboardController", ($scope, $location, $firebase, $routeParams, $rootScope, orgBuilder) ->
  $rootScope.title = "Dashboard"
  $scope.fromService = orgBuilder.getHouseholdsFromOrg()
  console.log($scope.fromService)
  $rootScope.currentUser = JSON.parse(sessionStorage.getItem("user"))
  $rootScope.SRA = JSON.parse(localStorage.SRA)
  $scope.firstName = $rootScope.currentUser.firstName
  $scope.lastName = $rootScope.currentUser.lastName
  console.log($scope.firstName)
  return

window.app.controller "AdminUsersController", ($scope, $location, $firebase, $routeParams, $rootScope, firebaseURL) ->
  $rootScope.currentUser = JSON.parse(sessionStorage.getItem("user"))
  $scope.users = []
  ref = new Firebase(firebaseURL + "Organizations/SRA/Users")
  users = $firebase(ref).$asArray()
  users.$loaded().then (data) ->   
    for user in data
      fb = new Firebase(firebaseURL + "Users/"+ user.$id)
      sync = $firebase(fb).$asObject()
      
      sync.$loaded().then (userObj) ->
        console.log(userObj)
        if(userObj.Email != undefined)
          $scope.users.push userObj
        
    return
  return

window.app.controller "EditUsersController", ($scope, $location, $firebase, $routeParams, $rootScope, firebaseURL) ->
  $rootScope.currentUser = JSON.parse(sessionStorage.getItem("user"))
  $scope.username = $routeParams.id
  $scope.UpdateUser = ->
    fname = $scope.user.fname
    lname = $scope.user.lname
    ref = new Firebase(firebaseURL + "Organizations/SRA/Users/" + $scope.username)
    sync = $firebase(ref)
    sync.$update(
      FirstName: fname
      LastName: lname
    ).then ((ref) ->
      ref.key() # bar
      return
    ), (error) ->
      return

    return

  return

window.app.controller "AreasUsersController", ($scope, $location, $firebase, $routeParams, $rootScope, firebaseURL) ->
  $rootScope.currentUser = JSON.parse(sessionStorage.getItem("user"))
  $scope.regions = JSON.parse(localStorage.getItem("regions"))
  localStorage.regionParam = $routeParams.name  if $routeParams.name isnt `undefined`
  localStorage.usernameParam = $routeParams.id  if $routeParams.id isnt `undefined`
  localStorage.areaParam = $routeParams.area  if $routeParams.area isnt `undefined`
  localStorage.countryParam = $routeParams.country if $routeParams.country isnt 'undefined'
  $scope.region = localStorage.regionParam
  $scope.username = localStorage.usernameParam
  $scope.area = localStorage.areaParam
  $scope.country = localStorage.countryParam
  countryRef = new Firebase(firebaseURL + "Organizations/SRA/Countries")
  countries = $firebase(countryRef).$asArray()
  countries.$loaded().then (data) ->
    $scope.countries = data
    console.log(data)
    return
  if $scope.country != undefined
    regionRef = new Firebase(firebaseURL + "Organizations/SRA/Countries/"+ $scope.country+"Regions")
    region = $firebase(countryRef).$asArray()
    region.$loaded().then (data) ->
      $scope.regions = data
      return

   

  $scope.AreaAssignemnt = ->
    ref = new Firebase(firebaseURL + "Users/" + $scope.username + "/Organizations/SRA/Regions")
    sync = $firebase(ref).$asArray
    ref.push ref.child($scope.region).child($scope.area).set(Name: $scope.area)
    $location.path "/"
    $scope.$apply()
    return

  return

window.app.controller "NewUsersController", ($scope, $location, $firebase, $routeParams, $rootScope, $firebaseAuth, firebaseURL) ->
  $rootScope.currentUser = JSON.parse(sessionStorage.getItem("user"))
  $scope.CreateUser = ->
    userNode = new Firebase(firebaseURL + "Organizations/SRA/Users")
    email = $scope.user.email
    password = $scope.user.password
    fname = $scope.user.fname
    lname = $scope.user.lname
    ref = new Firebase(firebaseURL)
    $scope.authObj = $firebaseAuth(ref)
    $scope.authObj.$createUser(email, password).then(->
      userNode.push userNode.child(email.split("@")[0]).set(
        FirstName: fname
        LastName: lname
      )
      $scope.authObj.$authWithPassword
        email: email
        password: email

    ).catch (error) ->
      console.error "Error: ", error
      return

    return

  return

window.app.controller "AreasNewController", ($scope, $location, $firebase, $routeParams, $rootScope, firebaseURL) ->
  $rootScope.currentUser = JSON.parse(sessionStorage.getItem("user"))
  $scope.regions = JSON.parse(localStorage.getItem("regions"))
  region = $routeParams.name
  $scope.region = $routeParams.name
  ref = new Firebase(firebaseURL + "Organizations/SRA/Regions/" + region + "/Areas")
  areasRef = new Firebase(firebaseURL + "Organizations/SRA/Regions/" + region)
  areas = $firebase(areasRef).$asArray()
  areas.$loaded ->
    $scope.areas = areas[0]
    return

  $scope.CreateArea = ->
    name = $scope.area.name
    ref.push ref.child(name).set(Name: name)
    return

  return

window.app.controller "AreasEditController", ($scope, $location, $firebase, $routeParams, firebaseURL) ->
  $scope.area = $routeParams.name
  $scope.region = $routeParams.region
  $scope.UpdateArea = ->
    ref = new Firebase(firebaseURL + "Organizations/SRA/Regions/" + $scope.region + "/Areas/" + $scope.area)
    name = $scope.Area.name
    ref.set name
    return

  return

window.app.controller "AdminHouseholdsController", ($scope, $rootScope, $location, $firebase, $routeParams, firebaseURL, orgBuilder) ->
  $scope.fromService = orgBuilder.getHouseholdsFromOrg();
  console.log($rootScope.households)
  return

