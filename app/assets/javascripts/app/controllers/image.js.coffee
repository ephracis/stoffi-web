@app.controller 'ImageController', ($scope, $http) ->
  
  # Width of the image.
  $scope.width = 0
  
  # Height of the image.
  $scope.height = 0
  
  # Fetch the size of the image's URL.
  $scope.fetchSize = (url) ->
    img = new Image()
    $scope.loadingImage = true
    img.onload = ->
      $scope.height = this.height
      $scope.width = this.width
      $scope.loadingImage = false
    img.src = url