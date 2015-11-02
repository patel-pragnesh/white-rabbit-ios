'use strict'

app = angular.module 'angularParseBoilerplate', [
  'ng'
  'ngResource'
  'ui.router'
  'ui.bootstrap'
  'app.templates'
  'Parse'
  'angulartics'
  'angulartics.google.analytics'
]

app.config (
  $locationProvider
  $stateProvider
  $urlRouterProvider
  ParseProvider
) ->

  $locationProvider.hashPrefix '!'

  $stateProvider
  .state 'trait',
    url: '/:locale'
    controller: 'TraitCtrl'
    templateUrl: 'trait.html'

  $urlRouterProvider.otherwise '/fr'

  ParseProvider.initialize(
    "IWr9xzTirLbjXH80mbTCtT9lWB73ggQe3PhA6nPg", # Application ID
    "SkDTdS8SBGzO9BkRHR3H8kwxCLJSvKsAe1jeOTnW"  # REST API Key
  )

app.run ($rootScope, $state) ->
  $rootScope.$state = $state
