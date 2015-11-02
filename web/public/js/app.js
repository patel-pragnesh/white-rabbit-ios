'use strict';
var app;

app = angular.module('angularParseBoilerplate', ['ng', 'ngResource', 'ui.router', 'ui.bootstrap', 'app.templates', 'Parse', 'angulartics', 'angulartics.google.analytics']);

app.config(function($locationProvider, $stateProvider, $urlRouterProvider, ParseProvider) {
  $locationProvider.hashPrefix('!');
  $stateProvider.state('trait', {
    url: '/:locale',
    controller: 'TraitCtrl',
    templateUrl: 'trait.html'
  });
  $urlRouterProvider.otherwise('/fr');
  return ParseProvider.initialize("IWr9xzTirLbjXH80mbTCtT9lWB73ggQe3PhA6nPg", "SkDTdS8SBGzO9BkRHR3H8kwxCLJSvKsAe1jeOTnW");
});

app.run(function($rootScope, $state) {
  return $rootScope.$state = $state;
});

app.controller('TraitCtrl', function($scope, Trait) {
  $scope.addTrait = function() {
    $scope.newTrait.save().then(function(trait) {
      return $scope.fetchTraits();
    });
    return $scope.newTrait = new Trait;
  };
  $scope.removeTrait = function(trait) {
    return trait.destroy().then(function() {
      return _.remove($scope.traits, function(trait) {
        return trait.objectId === null;
      });
    });
  };
  $scope.editingTrait = function(trait) {
    return trait.editing = true;
  };
  $scope.editTrait = function(trait) {
    trait.save();
    return trait.editing = false;
  };
  $scope.cancelEditing = function(trait) {
    trait.title = trait._cache.title;
    return trait.editing = false;
  };
  $scope.fetchTraits = function() {
    return Trait.query().then(function(traits) {
      return $scope.traits = traits;
    });
  };
  $scope.fetchTraits();
  return $scope.newTrait = new Trait;
});

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

app.factory('Trait', function(Parse) {
  var Trait;
  return Trait = (function(_super) {
    __extends(Trait, _super);

    function Trait() {
      return Trait.__super__.constructor.apply(this, arguments);
    }

    Trait.configure("Trait", "name");

    return Trait;

  })(Parse.Model);
});
