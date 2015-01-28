(function() {
  window.app.service("currentUser", function($rootScope, $location, $firebase, $firebaseAuth, firebaseURL, orgBuilder) {
    this.requireLogin = function() {
      var currentUser;
      currentUser = this;
      return new Promise(function(resolve, reject) {
        return currentUser.currentUser().then(function(currentUser) {
          return resolve(currentUser);
        })["catch"](function() {
          return $rootScope.$apply(function() {
            return $location.path("/login");
          });
        });
      });
    };
    this.currentUser = function() {
      var stored;
      stored = sessionStorage.getItem("userId");
      if ($rootScope.currentUser != null) {
        return new Promise(function(resolve, reject) {
          return resolve($rootScope.currentUser);
        });
      } else if (stored != null) {
        return this.getUser(stored);
      } else {
        return new Promise(function(resolve, reject) {
          return reject(Error("No current user"));
        });
      }
    };
    this.authenticate = function(email, password) {
      var authObj, authed, ref;
      authed = this.authed(email);
      ref = new Firebase(firebaseURL);
      authObj = $firebaseAuth(ref);
      return authObj.$authWithPassword({
        email: email,
        password: password
      }).then(authed)["catch"](function(error) {
        console.error("Authentication Failed:", error);
      });
    };
    this.getUser = function(userName) {
      var ref, url, userObj;
      url = "" + firebaseURL + "/users/" + userName;
      ref = new Firebase(url);
      userObj = $firebase(ref).$asObject();
      return userObj.$loaded().then(function(user) {
        return $rootScope.currentUser = user;
      });
    };
    this.authed = function(email) {
      var currentUser, getUser, loginRedirect;
      currentUser = this;
      getUser = this.getUser;
      loginRedirect = this.loginRedirect;
      return function() {
        var userName;
        userName = email.split("@").shift();
        return getUser(userName).then(function(userData) {
          orgBuilder.userCache(userData);
          return currentUser.currentUser().then(loginRedirect);
        });
      };
    };
    this.loginRedirect = function(user) {
      var error;
      try {
        if (user.organizations.sra.roles.name === "admin") {
          $location.path("/admin/dashboard");
        } else {
          $location.path("/dashboard");
        }
      } catch (_error) {
        error = _error;
        console.log("Error thrown");
        throw error;
      }
    };
  });

}).call(this);

(function() {
  window.app.service("orgBuilder", function($firebase, $rootScope) {
    var flatten;
    this.userCache = function(user) {
      var id;
      $rootScope.currentUser = user;
      id = user.$id;
      sessionStorage.setItem("userId", id);
      return user;
    };
    this.getAreasFromRegion = function(region) {
      var ref, sync;
      ref = new Firebase("https://intense-inferno-7741.firebaseio.com/organizations/sra/countries/" + region.country + "/regions/" + region.name + "/areas");
      sync = $firebase(ref).$asArray().then();
      return sync.$loaded().then(function(data) {
        return data;
      });
    };
    this.getRegionsFromCountry = function(country) {
      return country.regions;
    };
    this.getCountriesFromOrg = function() {
      var countries, ref;
      countries = {};
      ref = new Firebase("https://intense-inferno-7741.firebaseio.com/organizations/sra/countries");
      return $firebase(ref).$asArray().$loaded();
    };
    flatten = function(array) {
      return [].concat.apply([], array);
    };
    this.getHouseholdsFromArea = function(area) {
      var household, key;
      return flatten((function() {
        var _ref, _results;
        _ref = area.resources;
        _results = [];
        for (key in _ref) {
          household = _ref[key];
          _results.push(household);
        }
        return _results;
      })());
    };
    this.getHouseholdsFromRegion = function(region) {
      var area, name;
      return flatten((function() {
        var _ref, _results;
        _ref = region.areas;
        _results = [];
        for (name in _ref) {
          area = _ref[name];
          _results.push(this.getHouseholdsFromArea(area));
        }
        return _results;
      }).call(this));
    };
    this.getHouseholdsFromCountry = function(country) {
      var name, region;
      return flatten((function() {
        var _ref, _results;
        _ref = country.regions;
        _results = [];
        for (name in _ref) {
          region = _ref[name];
          _results.push(this.getHouseholdsFromRegion(region));
        }
        return _results;
      }).call(this));
    };
    this.getHouseholdsFromOrg = function($scope) {
      var callback, orgBuilder, ref, sync;
      ref = new Firebase("https://intense-inferno-7741.firebaseio.com/organizations/sra/countries");
      sync = $firebase(ref).$asArray();
      orgBuilder = this;
      callback = function(countries) {
        var country, households;
        households = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = countries.length; _i < _len; _i++) {
            country = countries[_i];
            _results.push(orgBuilder.getHouseholdsFromCountry(country));
          }
          return _results;
        })();
        $rootScope.households = flatten(households);
        return console.log($rootScope.households);
      };
      return sync.$loaded().then(callback);
    };
  });

}).call(this);

(function() {
  window.app.service("User", function($firebase, $firebaseAuth, firebaseURL) {
    this.all = function($scope) {
      var User, ref, users;
      $scope.users = [];
      User = this;
      ref = new Firebase("" + firebaseURL + "organizations/sra/users");
      users = $firebase(ref).$asArray();
      return users.$loaded().then(function(data) {
        var user, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          user = data[_i];
          _results.push(User.find(user.$id).then(function(userObj) {
            if (userObj.email !== void 0) {
              return $scope.users.push(userObj);
            }
          }));
        }
        return _results;
      });
    };
    this.find = function(id) {
      var ref, url, user;
      url = "" + firebaseURL + "users/" + id;
      ref = new Firebase(url);
      user = $firebase(ref).$asObject();
      return user.$loaded();
    };
  });

}).call(this);
