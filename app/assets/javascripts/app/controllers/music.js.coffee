@app.controller 'MusicController', ['$scope', '$location', '$window', ($scope, $location, $window) ->
  
  available = ['playlists', 'songs', 'artists', 'albums', 'events', 'genres']
  
  $scope.getList = ->
    paths = $location.path().split('/')
    def = 'playlists'
    if paths.length > 1 and paths[1] in available
      return paths[1]
    return def
    
  $scope.setList = (list) ->
    return unless list in available
    $location.path("/#{list}")
    updateTitle()
    $scope.list = list
    
  updateTitle = ->
    title = I18n.t("music.titles.#{$scope.getList()}")
    $window.document.title = "#{title} - Stoffi"
    
  updateTitle()
    
  $scope.$watch () ->
    $location.absUrl()
  , () ->
    $scope.list = $scope.getList()
]