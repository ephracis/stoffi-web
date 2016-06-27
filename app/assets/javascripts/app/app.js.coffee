@app = angular.module 'Stoffi', ['ngMap', 'angulartics', 'angulartics.google.analytics', 'ui.sortable'], ($locationProvider) ->
  $locationProvider.html5Mode {
    enabled: true,
    requireBase: false
  }