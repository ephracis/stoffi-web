@app.controller 'DashboardController', ['$scope', '$location', '$window', ($scope, $location, $window) ->
  
  available = ['stats', 'rank', 'activity', 'devices']
  default_tab = 'activity'
  
  $scope.getTab = ->
    paths = $location.path().split('/')
    if paths.length > 1 and paths[1] == 'devices'
      return 'devices'
    else if paths.length > 2 and paths[2] in available
      return paths[2]
    return default_tab
    
  $scope.setTab = (tab) ->
    return unless tab in available
    if tab == default_tab
      $location.path '/dashboard'
    else if tab == 'devices'
      $location.path '/devices'
    else
      $location.path("/dashboard/#{tab}")
    updateTitle()
    $scope.tab = tab
    
  updateTitle = ->
    title = I18n.t("accounts.dashboard.#{$scope.getTab()}.title")
    $window.document.title = "#{title} - Stoffi"
    
  updateTitle()
    
  $scope.$watch () ->
    $location.absUrl()
  , () ->
    $scope.tab = $scope.getTab()
]
