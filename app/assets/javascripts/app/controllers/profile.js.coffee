@app.controller 'ProfileController', ['$scope', '$location', '$window', '$http', ($scope, $location, $window, $http) ->
  
  available_tabs = ['listens', 'toplists', 'activity', 'playlists']
  default_tab = 'playlists'
  
  #the user's info
  $scope.slug = 'me'
  $scope.name = 'Anon'
  $scope.isLocked = false
  $scope.isAdmin = false
  
  # Set the info of the user given their slug.
  $scope.setUser = (slug) ->
    $http( { method: 'GET', url: "/#{slug}.json" }).then(
      $scope.loadUser, () -> nil)
    
  # Load user data from a JSON response.
  $scope.loadUser = (response) ->
    return unless response.data
    $scope.name = response.data.name
    $scope.slug = response.data.slug
    $scope.isLocked = response.data.locked
    $scope.isAdmin = response.data.admin
    updateTitle()
    
  # Toggle the lock status of a user.
  $scope.toggleLock = () ->
    if $scope.isLocked
      locked_at = (new Date()).toString()
    else
      locked_at = ''
    data = { user: { locked_at: locked_at } }
    
    $http.patch("/settings/#{$scope.slug}.json", data).then(
      () -> 
    , () ->
        $scope.isLocked = !$scope.isLocked
    )
    
  # Toggle the admin status of a user.
  $scope.toggleAdmin = () ->
    data = { user: { admin: $scope.isAdmin } }
    
    $http.patch("/settings/#{$scope.slug}.json", data).then(
      () -> 
    , () ->
        $scope.isAdmin = !$scope.isAdmin
    )
  
  # Get the currently active tab.
  $scope.getTab = ->
      paths = $location.path().split('/')
      if paths.length > 2 and paths[2] in available_tabs
        return paths[2]
      return default_tab

  # Change the currently active tab.
  $scope.setTab = (tab) ->
    return unless tab in available_tabs
    if tab == default_tab
      $location.path "/#{$scope.slug}"
    else
      $location.path("/#{$scope.slug}/#{tab}")
    updateTitle()
    $scope.tab = tab

  # Update the title on the page according to the currently selected tab.
  updateTitle = ->
    title = I18n.t("accounts.profile.#{$scope.getTab()}.title")
    $window.document.title = "#{title} - #{$scope.name} - Stoffi"
    
  updateTitle()
    
  $scope.$watch () ->
    $location.absUrl()
  , () ->
    $scope.tab = $scope.getTab()
]